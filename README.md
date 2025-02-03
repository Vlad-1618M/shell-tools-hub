# shell-tools-hub
> A collection of shell scripts designed to automate everyday tasks and streamline workflows and enhance productivity: <br>
---
> Features:
>- Automated System Operations: Scripts for package management, system checks, and process monitoring.
>- Docker & Kubernetes Management: Easily handle containerized environments.
>- Firewall & Network Tools: Secure and monitor network traffic efficiently.
>- File & Log Management: Organize, search, and monitor system logs.
>- Custom Utility Scripts: Various helper scripts to simplify automation tasks.
---
```bash
shell-tools-hub
├── 📜 LICENSE
├── 📖 README.md
└── 📂 src
    ├── 📁 for_ansible
    │   └── 📜 install_ansible_galaxy_libs.sh
    ├── 📁 for_docker
    │   ├── 📜 active_container_logs.sh
    │   ├── 📜 docker_cleanup.sh
    │   ├── 📜 docker_container_stats.sh
    │   ├── 📜 install_docker_compose.sh
    │   └── 📜 redhat_docker_install.sh
    ├── 📁 for_helm
    │   └── 📜 helm_install.sh
    ├── 📁 for_kubectl
    │   └── 📜 kubectl_install.sh
    ├── 📁 for_local_sys
    │   ├── 📜 apple_device_details.sh
    │   ├── 📜 deps_check_sys_tools.sh
    │   ├── 📜 kill_terminal_sessions.sh
    │   ├── 📜 new_terminal.sh
    │   └── 📜 vmstats.sh
    ├── 📁 for_network
    │   ├── 📂 cfgs
    │   │   ├── 🗒️ hosts.cfg
    │   │   ├── 🗒️ native_tshark_cli_help.cfg
    │   │   └── 🗒️ ssh.cfg
    │   ├── 📂 domains
    │   │   ├── 🗒️ domains.cfg
    │   │   └── 📜 fqdn_ip_logger.sh
    │   ├── 📜 firewalld.sh
    │   ├── 📜 ip_tracer.sh
    │   ├── 📜 net_stats_trace.sh
    │   ├── 📜 nmaps.sh
    │   ├── 📜 ports_ps_kill.sh
    │   ├── 📜 selinux_check.sh
    │   ├── 📜 setup_ssh_keys.sh
    │   └── 📜 tshark.sh
    ├── 📁 pkg_tar
    │   ├── 📜 create_tar_pkg.sh
    │   └── 📜 untar_pkg.sh
    ├── 📁 random_scripts
    │   └── 📂 open_urls_in_browser
    │       ├── 🗒️ cfg.ini
    │       ├── 🗒️ ebom.txt
    │       ├── 📜 good_old_days.sh
    │       └── 📜 open_urls.sh
    ├── 📁 read_files
    │   ├── 📜 file_observer.sh
    │   ├── 📜 find_files.sh
    │   └── 📜 smart_cat_highlighter.sh
    └── 📁 shell_notes
        └── 🗒️ oneliners.ini
```
# Installation & Usage
---
>- Clone the repository:
``` bash
git clone https://github.com/Vlad-1618M/shell-tools-hub.git
cd shell-tools-hub/src
```
>- Make a script executable and run it:
``` bash
chmod u+x for_docker/docker_cleanup.sh
./for_docker/docker_cleanup.sh
```
>- To list available scripts:
``` bash
    find src -type f -name "*.sh"
```
---
>- Contribution <br>
> Feel free to contribute by submitting a pull request or opening an issue: <br> Ensure scripts follow best practices and include comments where necessary:
---
### License
- This project is licensed under the MIT License - see the [MIT License](LICENSE) file for details: 
---
### Hope It Helps! - Enjoy and Happy Coding ! 
### :0)
---