# Frappe-ERPNext Installation Script

This script automates the installation process for Frappe/ERPNext Version-15 on Ubuntu 22.04 LTS. It handles all necessary dependencies, configurations, and initialization steps to get your Frappe/ERPNext instance up and running with a test app.

## Motivation

<details>
  <summary>Click to expand the motivation section</summary>
When I interned at Frappe, setting up my bench and getting started took up to a week of internet searches and trial and error. Back then the process was tedious, involving extensive copying and pasting of commands and encountering a lot errors and dependencies issues, which left me feeling lost.

<br>

I lacked a lot of knowledge that I've since gained, and I want to give back. The goal of this bash script is straightforward: to streamline the setup of Frappe bench, reducing the time from one week to minutes, getting it up and running ASAP. Previously, the process was convoluted, requiring multiple steps and dependencies. This installer aims to simplify everything with **just one command** . You don't even need to worry about having git or curl installed on your system; this installer, in similar fashion to Frappe framework, comes batteries included. From start to finish, it's all done with a single command.

</details>

## Demo

Here's to a demo installation on a freshly spun Virtual Machine running Ubuntu 22 LTS, making the process as swift and seamless as possible.

[![Demo Video](https://img.youtube.com/vi/ybNjt5Y1OCo/0.jpg)](https://www.youtube.com/watch?v=ybNjt5Y1OCo)

## Installation Steps

1. **Download and Run the Script: (Recommended)**

Execute the following command in your terminal:

```bash
wget -O installer.sh https://raw.githubusercontent.com/anxkhn/frappe-installer-bash/main/installer.sh && chmod +x installer.sh && ./installer.sh
```

- If you are unable to resolve raw.githubusercontent.com it might be due to India blocking GitHub's content domain and preventing downloads. Source: <https://timesofindia.indiatimes.com/gadgets-news/github-content-domain-blocked-for-these-indian-users-reports/articleshow/96687992.cms>

You may use a VPN, change your DNS provider to Google/Cloudflare/etc or use the following step to download the script and run it locally.

1. **Clone the Repository and Run the Script:**

Execute the script by running:

```bash
sudo apt install -y git
git clone https://github.com/anxkhn/frappe-installer-bash
cd frappe-installer-bash
chmod +x installer.sh
./installer.sh
```

This script will automatically install Frappe/ERPNext along with all required dependencies and configurations.

2. **Enter Necessary Passwords:**

During the installation process, you will be prompted to enter the following passwords:

- **Root Password:** Enter the password for root user to install necessary dependencies.
- **MariaDB Root Password:** Enter a secure password for the MariaDB root user.
- **Administrator Password:** Enter a secure password for the Frappe/ERPNext administrator.

Make sure to remember these passwords as they will be required to access the Frappe/ERPNext instance.

4. **Access Frappe/ERPNext:**

Once the installation completes successfully, access Frappe/ERPNext by navigating to http://hello.com:8000 in your web browser.

5. **Additional Information:**

- For detailed information on the setup and configuration of individual components, refer to - [D-codeE Video Tutorial](https://youtu.be/TReR0I0O1Xo) and [D-codeE Github Repo](https://github.com/D-codE-Hub/Frappe-ERPNext-Version-15--in-Ubuntu-22.04-LTS/tree/main)
- For more information on the installation process, refer to the [Frappe/ERPNext Documentation](https://frappeframework.com/docs/user/en)

## Future Work

- [ ] Implement resuming from a missing step
- [ ] Introduce command-line arguments for additional options
- [ ] Implement debug tools to check packages and configurations
- [ ] Enhance command-line output with colors for better readability
- [ ] Improve handling of existing installed packages
- [ ] Improve error handling with proper status codes
- [ ] Add support for MacOS

## References

- [Frappe Framework Documentation](https://frappeframework.com/docs/user/en)
- [Frappe Bench Documentation](https://frappeframework.com/docs/user/en/bench)
