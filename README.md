## A collection of shell scripts designed to automate everyday tasks, streamline workflows to enhance productivity: <br>

## Features:
>- **Automated System Operations:** <br>
&nbsp;&nbsp;&nbsp;Manage system processes / deps with scripts for: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Package installation and dependency checks: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- System resource monitoring: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Managing terminal sessions: <br>

>- **Docker & Kubernetes Management:** <br> 
&nbsp;&nbsp;&nbsp;Handle containerized environments with scripts for: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Docker Engine Installations: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Container lifecycle management: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Monitoring container statistics: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Kubernetes setup and deployment: <br>

>- **Firewall & Network Tools:** <br> 
&nbsp;&nbsp;&nbsp;Secure and monitor network traffic efficiently with tools for:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Configuring firewall rules: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Network diagnostics: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Managing SSH keys and sessions: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Tracking domain IP addresses: <br>

>- **File & Log Management:** <br> 
&nbsp;&nbsp;&nbsp;Enhance file handling and log monitoring with scripts to: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Locate and manage files: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Key-word based read and highlight important file entries: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Extract and parse log details <br>

>- **Custom Utility Scripts:** <br> 
&nbsp;&nbsp;&nbsp;A variety of helper scripts to simplify automation tasks, including: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Extracting IP addresses from domain names: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Handling compressed archives: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Automating browser-based workflows: <br>

### The Shell Script collection is built for `cross-platform compatibility` ensuring automation across `Linux` and `macOS` environments:<br>
shell-tools-hub  <br>
├── 📜 [LICENSE](LICENSE) <br>
├── 📖 [README.md](README.md) <br>
└── 📂 [src](src) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [for_ansible](src/for_ansible) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📜 [install_ansible_galaxy_libs.sh](src/for_ansible/install_ansible_galaxy_libs.sh) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [for_docker](src/for_docker) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [active_container_logs.sh](src/for_docker/active_container_logs.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [docker_cleanup.sh](src/for_docker/docker_cleanup.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [docker_container_stats.sh](src/for_docker/docker_container_stats.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [install_docker_compose.sh](src/for_docker/install_docker_compose.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📜 [redhat_docker_install.sh](src/for_docker/redhat_docker_install.sh) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [for_helm](src/for_helm) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📜 [helm_install.sh](src/for_helm/helm_install.sh) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [for_kubectl](src/for_kubectl) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📜 [kubectl_install.sh](src/for_kubectl/kubectl_install.sh) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [for_local_sys](src/for_local_sys) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [apple_device_details.sh](src/for_local_sys/apple_device_details.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [deps_check_sys_tools.sh](src/for_local_sys/deps_check_sys_tools.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [kill_terminal_sessions.sh](src/for_local_sys/kill_terminal_sessions.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [new_terminal.sh](src/for_local_sys/new_terminal.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📜 [vmstats.sh](src/for_local_sys/vmstats.sh) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [for_network](src/for_network) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📂 [cfgs](src/for_network/cfgs) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 🗒️ [hosts.cfg](src/for_network/cfgs/hosts.cfg) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 🗒️ [native_tshark_cli_help.cfg](src/for_network/cfgs/native_tshark_cli_help.cfg) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 🗒️ [ssh.cfg](src/for_network/cfgs/ssh.cfg) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📂 [domains](src/for_network/domains) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 🗒️ [domains.cfg](src/for_network/domains/domains.cfg) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📜 [fqdn_ip_logger.sh](src/for_network/domains/fqdn_ip_logger.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [firewalld.sh](src/for_network/firewalld.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [ip_tracer.sh](src/for_network/ip_tracer.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [net_stats_trace.sh](src/for_network/net_stats_trace.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [nmaps.sh](src/for_network/nmaps.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [ports_ps_kill.sh](src/for_network/ports_ps_kill.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [selinux_check.sh](src/for_network/selinux_check.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [setup_ssh_keys.sh](src/for_network/setup_ssh_keys.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;└── 📜 [tshark.sh](src/for_network/tshark.sh) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [pkg_tar](src/pkg_tar) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [create_tar_pkg.sh](src/pkg_tar/create_tar_pkg.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📜 [untar_pkg.sh](src/pkg_tar/untar_pkg.sh) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [random_scripts](src/random_scripts) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└── 📂 [open_urls_in_browser](src/random_scripts/open_urls_in_browser) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── 🗒️ [cfg.ini](src/random_scripts/open_urls_in_browser/cfg.ini) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── 🗒️ [ebom.txt](src/random_scripts/open_urls_in_browser/ebom.txt) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── 📜 [good_old_days.sh](src/random_scripts/open_urls_in_browser/good_old_days.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── 📜 [open_urls.sh](src/random_scripts/open_urls_in_browser/open_urls.sh) <br>
&nbsp;&nbsp;&nbsp;├── 📁 [read_files](src/read_files) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [file_observer.sh](src/read_files/file_observer.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├── 📜 [find_files.sh](src/read_files/find_files.sh) <br>
&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;└── 📜 [smart_cat_highlighter.sh](src/read_files/smart_cat_highlighter.sh) <br>
&nbsp;&nbsp;&nbsp;└── 📁 [shell_notes](src/shell_notes) <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└── 🗒️ [oneliners.ini](src/shell_notes/oneliners.ini) <br>
---

# Installation & Usage
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