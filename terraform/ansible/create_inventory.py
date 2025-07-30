#!/usr/bin/env python3
import json
import os
import sys

def generate_yaml(inventory):
    """Генерация YAML инвентаря без внешних зависимостей"""
    yaml_lines = []
    
    def add_section(name, value, indent=0):
        spaces = '  ' * indent
        if isinstance(value, dict):
            yaml_lines.append(f"{spaces}{name}:")
            for k, v in value.items():
                add_section(k, v, indent + 1)
        elif isinstance(value, list):
            for item in value:
                add_section(name, item, indent)
        else:
            yaml_lines.append(f"{spaces}{name}: {value}")
    
    for section, content in inventory.items():
        add_section(section, content)
    return '\n'.join(yaml_lines)

def main():
    try:
        # Путь к файлу output.json
        output_dir = os.path.join(os.path.dirname(__file__), 'inventory')
        output_path = os.path.join(output_dir, 'output.json')
        
        # Проверка существования файла
        if not os.path.exists(output_path):
            print(f"Error: Terraform output file not found at {output_path}")
            sys.exit(1)
        
        # Загрузка вывода Terraform
        with open(output_path) as f:
            tf_output = json.load(f)
        
        # Функция для безопасного получения значений
        def get_tf_value(key, default=""):
            try:
                return tf_output[key]['value']
            except (KeyError, TypeError):
                return default
        
        # Получение IP-адресов
        bastion_ip = get_tf_value('bastion_ip', '')
        kibana_ip = get_tf_value('kibana_ip', '')
        zabbix_ip = get_tf_value('zabbix_ip', '')
        elastic_ip = get_tf_value('elastic_ip', '')
        web_ips = get_tf_value('web_ips', [])
        
        # Проверка наличия критических IP
        if not bastion_ip:
            print("Error: Bastion IP not found in Terraform output")
            sys.exit(1)
            
        if not web_ips:
            print("Error: Web server IPs not found in Terraform output")
            sys.exit(1)
        
        # Общие параметры SSH для всех хостов
        common_ssh_args = (
            '-o StrictHostKeyChecking=no '
            '-o UserKnownHostsFile=/dev/null '
            '-o GlobalKnownHostsFile=/dev/null'
        )
        
        # Формат ProxyCommand для внутренних хостов
        proxy_command = f'-o ProxyCommand="ssh -W %h:%p -q ubuntu@{bastion_ip}"'
        
        # Создание структуры инвентаря
        inventory = {
            'all': {
                'vars': {
                    'ansible_user': 'ubuntu',
                    'ansible_ssh_private_key_file': '~/.ssh/id_rsa_diploma',
                    'ansible_ssh_common_args': common_ssh_args
                },
                'children': {
                    'bastion': {
                        'hosts': {
                            'bastion.ru-central1.internal': {
                                'ansible_host': bastion_ip
                            }
                        }
                    },
                    'web': {
                        'hosts': {
                            f'web-{i}.ru-central1.internal': {
                                'ansible_host': ip,
                                'ansible_ssh_common_args': f'{common_ssh_args} {proxy_command}'
                            } for i, ip in enumerate(web_ips)
                        }
                    },
                    'elastic': {
                        'hosts': {
                            'elastic.ru-central1.internal': {
                                'ansible_host': elastic_ip,
                                'ansible_ssh_common_args': f'{common_ssh_args} {proxy_command}'
                            }
                        }
                    },
                    'kibana': {
                        'hosts': {
                            'kibana.ru-central1.internal': {
                                'ansible_host': kibana_ip,
                                'ansible_ssh_common_args': f'{common_ssh_args} {proxy_command}'
                            }
                        }
                    },
                    'zabbix': {
                        'hosts': {
                            'zabbix.ru-central1.internal': {
                                'ansible_host': zabbix_ip,
                                'ansible_ssh_common_args': f'{common_ssh_args} {proxy_command}'
                            }
                        }
                    }
                }
            }
        }
        
        # Путь для сохранения production.yml
        output_yaml = os.path.join(output_dir, 'production.yml')
        
        # Генерация YAML
        yaml_content = generate_yaml(inventory)
        
        # Сохранение в файл
        with open(output_yaml, 'w') as f:
            f.write(yaml_content)
        
        print(f"Inventory successfully generated at {output_yaml}")
        
        # Проверка подключения к бастиону
        print("\nTesting Bastion connection...")
        bastion_test = os.system(
            f"ssh -i ~/.ssh/id_rsa_diploma -o StrictHostKeyChecking=no ubuntu@{bastion_ip} 'echo Success'"
        )
        if bastion_test != 0:
            print("Error: Failed to connect to Bastion host")
            sys.exit(1)
            
        # Проверка подключения к внутреннему хосту через бастион
        test_host = web_ips[0] if web_ips else elastic_ip
        if test_host:
            print("\nTesting internal host connection via Bastion...")
            internal_test = os.system(
                f"ssh -i ~/.ssh/id_rsa_diploma {common_ssh_args} "
                f"{proxy_command} ubuntu@{test_host} 'echo Success'"
            )
            if internal_test != 0:
                print("Error: Failed to connect to internal host via Bastion")
                sys.exit(1)
        
        print("\nConnection tests passed successfully!")
        return 0
    
    except Exception as e:
        print(f"Error generating inventory: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()