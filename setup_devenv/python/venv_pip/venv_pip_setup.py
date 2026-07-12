import shutil
import site
import sys
import subprocess
import tempfile
import venv
from argparse import ArgumentParser
from datetime import datetime
from pathlib import Path
from textwrap import dedent

RUNNING_IN_VENV = sys.prefix != sys.base_prefix
DEFAULT_PYTHON_VERSION = "3.13.14"
PYTHON_FULL_VERSIONS = {
    "3.13.14": (3, 13, 14),
    "3.12.13": (3, 12, 13),
    "3.11.15": (3, 11, 15),
}
COMMANDS_FILE_PATH = Path.home() / ".virtualenvs" / "bin" / "venv_commands.sh"
COMMANDS_FILE_TEMPLATE_PATH = Path(__file__).parent / "templates" / "venv_commands.sh-template"

class StopException(Exception):
    """Custom exception to stop the script execution."""
    pass

def install_python_version(version: str) -> None:
    """
    Install the specified Python version apt for Ubuntu/Debian OS.
    """
    # sudo apt update
    # sudo apt install software-properties-common -y
    # sudo add-apt-repository ppa:deadsnakes/ppa -y
    # sudo apt update
    # Replace '3.13' with your desired version number
    # sudo apt install python3.13 python3.13-venv -y 

def check_python_version(python_version: str) -> None:
    """
    Check if the specified Python version is installed.
    """
    print(f">>> Checking if Python version {python_version} is installed")
    python_major_and_minor = '.'.join(python_version.split('.')[:2])
    try:
        subprocess.run([f"python{python_major_and_minor}", "--version"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: Python version {python_version} is not installed.\nERROR: {e}")
        install_python_version(python_version)

def backup_by_rename(path: Path) -> None:
    """
    Rename the specified path to create a backup.
    """
    path_type = "directory" if path.is_dir() else "file"
    backup_path = path.with_name(f"{path.name}_backup_{datetime.now().strftime('%Y%m%d-%H%M%S')}")
    print(f"[yellow]Warning:[/] The {path_type} '{path}' already exists. Renaming it to '{backup_path}' as a backup.")
    input("Press [enter] to continue...")
    if backup_path.exists():
        raise StopException(f"Backup path '{backup_path}' already exists. Interrupting the script to avoid overwriting.")
    path.rename(backup_path)


def hard_reset_python_installation():
    """Perform the rename of the `global` Python installation directory, this way we keep
    the old installation as a backup and we can restore it if needed.
    """
    print(">>> Performing a hard reset of the `global` Python installation")
    user_base_path = Path(site.getuserbase())
    if user_base_path.exists():
        backup_by_rename(user_base_path)
    else:
        print(f">>> Warning: The user base path '{user_base_path}' does not exist. Skipping hard reset.")


def check_certificate_chain_file():
    """
    The `CERTIFICATE_CHAIN_FILE` environment variable is used to specify the path to a file that contains
    one or more CA certificates in PEM format, which are used to verify the authenticity of SSL/TLS certificates.
    """
    print(">>> Checking for `CERTIFICATE_CHAIN_FILE` environment variable")
    # TODO: to be implemented


def check_pip_conf_file():
    """
    Check if `pip.conf` file exists in the user's home directory.

    The `pip.conf` file is a configuration file used to configure the behavior of pip, the package
    installer for Python. This file allows users to specify default options for pip, such as the
    default index URL, timeout settings, and other configuration options.
    """
    print(">>> Checking for `pip.conf` file")
    # TODO: to be implemented


def check_netrc_file():
    """The `.netrc` file is a configuration file used on Unix-like operating systems to store login
    credentials for various network services, such as FTP, HTTP, and other services that require authentication.
    This file allows scripts and programs to automate connections to these services without requiring
    the user to input credentials manually every time.

    The structure of a `.netrc` file typically contains entries in the following format:
    ```bash
    machine <hostname>
    login <username>
    password <password>
    ```
    """
    print(">>> Checking for `.netrc` file")
    netrc_path = Path.home() / ".netrc"
    if netrc_path.exists():
        print(">>> `.netrc` file found")
    else:
        print(">>> `.netrc` file not found")


def build_and_activate_venv(python_version: str):
    """Starts a susprocess with the flag --inside-venv to execute the script again inside the
    virtual environment.
    """
    print(">>> Building and activating the Python virtual environment")
    with tempfile.TemporaryDirectory() as temp_dir:
        venv_path = Path(temp_dir) / ".virtualenvs/envs/venv_temp"
        print(f">>> Creating virtual environment at: {venv_path}")
        venv.create(venv_path, with_pip=True)
        venv_python_path = venv_path / "bin" / "python"
        venv_pip_path = venv_path / "bin" / "pip"
        
        print(">>> Installing 'rich' package in the virtual environment...")
        print("\t| If the Artifactory credentials are not configured, the installation may fail.")
        print("\t| So execute the installation script again...")
        subprocess.run([str(venv_pip_path), "install", "rich"], check=True)
        
        print("Re-executing the script inside the virtual environment...")
        script_command = [str(venv_python_path), __file__, "--python-version", python_version, "--inside-venv"]
        subprocess.run(script_command, check=True)


def copy_commands_file(python_version: str) -> None:
    """Creates the .virtualenvs folder with the commands file."""
    python_version_major_and_minor = '.'.join(python_version.split('.')[:2])
    if not COMMANDS_FILE_TEMPLATE_PATH.exists():
        raise FileNotFoundError(f"Template not found at '{COMMANDS_FILE_TEMPLATE_PATH}'")

    commands_template_content = COMMANDS_FILE_TEMPLATE_PATH.read_text()
    commands_template_content = commands_template_content.replace(
        "REPLACE_PYTHON_VERSION", f"python{python_version_major_and_minor}"
    )
    COMMANDS_FILE_PATH.parent.mkdir(parents=True, exist_ok=True)
    COMMANDS_FILE_PATH.write_text(commands_template_content)
    shutil.copymode(COMMANDS_FILE_TEMPLATE_PATH, COMMANDS_FILE_PATH)


def main() -> None:
    """
    Main function to set up the Python virtual environment and install pip packages.
    """
    parser = ArgumentParser()
    parser.add_argument(
        "--python-version",
        default=DEFAULT_PYTHON_VERSION,
        choices=PYTHON_FULL_VERSIONS.keys()
    )
    parser.add_argument(
        "--hard-reset",
        action="store_true",
        help="Perform a hard reset of the `global` Python virtual environment."
    )
    parser.add_argument(
        "--inside-venv",
        action="store_true",
        help="Indicates that the script is being executed inside a virtual environment."
    )

    args = parser.parse_args()
    try:
        if args.inside_venv:
            if not RUNNING_IN_VENV:
                raise StopException("This script must be run inside a virtual environment.")
            
            copy_commands_file(python_version=args.python_version)

        else:
            if RUNNING_IN_VENV:
                raise StopException(
                    "This script should not be run inside a virtual environment."
                    "Please `deactivate` the current virtual environment and run the script again."
                )
            print(">>> Starting validations without a venv activated")
            check_python_version(python_version=args.python_version)
            if args.hard_reset:
                hard_reset_python_installation()
            check_certificate_chain_file()
            check_pip_conf_file()
            check_netrc_file()
            build_and_activate_venv(python_version=args.python_version)

    except StopException as e:
        print(f"Error: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Subprocess execution error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
