# 42fetch
<img alt="42fetch" width="210" src="https://raw.githubusercontent.com/0xySan/42fetch/main/.gitlogo/42_logo.png" />

## 📥 Installation
To install 42fetch, run the following command:
```
curl https://raw.githubusercontent.com/0xySan/42fetch/main/install.sh | env CURL=true bash
```
## Configuration

### 🔹 Command-line Arguments
- `-h`, `--help`
	Display a help message.
- `-c=...`, `--config=...`
	- Specifies the path to a `.cfg` file if needed.
- `--no-config`
	- Disable the text from the config files.
- `-f=...`, `--flag=...`
	- Overrides colors with the chosen flag.
- `-l=...`, `--logo=...`
	- Choose the logo to be displayed.
	- `-m`, `--min`
		- Use the minimized version of the logo if available.
1. 🏳️‍🌈 Flags supported:

- `pride`
- `transgender`
- `lesbian`
- `bisexual`
- `pansexual`
- `nonbinary`
- `genderfluid`
- `agender`
- `intersex`
- `aromantic`
- `asexual`

2. Config options

- `$user` – Username

- `$hostmachine` – Hostname

- `$lengthuh` – Length of `$user` + `$hostmachine` (with `-`)

- `$os` – Operating system

- `$kernel` – Kernel version

- `$uptime` – System uptime

- `$packages` – Installed packages count

- `$shell` – Default shell

- `$resolution` – Screen resolution

- `$de` – Desktop Environment

- `$terminal` – Terminal emulator

- `$cpu` – Processor model

- `$gpu` – Graphics card model

- `$memory` – RAM usage

- `$ip` – Local IP address

- `$pip` – Public IP address

- `$lastboot` – Last system boot time

- `$pc` – Process count

- `$root` – Root partition usage

- `$home` – Home directory usage

💡 **Tip**: You can combine multiple logos/flags (e.g., Arch,42,blahaj), and one will be randomly selected at launch.

## 🔗 42 API Integration
If you want to use 42 api you need to create a `.env` with your credentials like this:
```sh
UID="your_UID"
SECRET="your_secret"
```
### 📊 Available 42 API Data
- `$level` – Current level
- `$progressBar` – Progress bar
- `$correctionPts` – Correction points
- `$wallets` – Wallet balance
- `$session` – Current session status
- `$duration` – Session duration