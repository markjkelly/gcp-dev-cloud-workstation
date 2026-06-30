import subprocess
import os

project = "prj-c-workstations-j68o"
region = "us-central1"
cluster = "workstation-cluster"
config = "ws-config"
workstation = "dev-workstation"

def run_ssh_command(cmd, stdin_data=None):
    gcloud_cmd = [
        "gcloud", "workstations", "ssh", workstation,
        f"--cluster={cluster}",
        f"--config={config}",
        f"--region={region}",
        f"--project={project}",
        "--quiet",
        f"--command={cmd}"
    ]
    print(f"Running: {' '.join(gcloud_cmd)}")
    
    proc = subprocess.Popen(
        gcloud_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    stdout, stderr = proc.communicate(input=stdin_data)
    
    print("STDOUT:")
    print(stdout)
    print("STDERR:")
    print(stderr)
    
    if proc.returncode != 0:
        raise Exception(f"Command failed with exit code {proc.returncode}")
    return stdout

# 1. Copy 09-sync.sh
with open("workstation-image/boot/09-sync.sh", "r") as f:
    sync_content = f.read()

print("Copying 09-sync.sh to remote workstation...")
run_ssh_command("cat > /home/user/boot/09-sync.sh", stdin_data=sync_content)

# 2. Copy 10-tests.sh
with open("workstation-image/boot/10-tests.sh", "r") as f:
    tests_content = f.read()

print("Copying 10-tests.sh to remote workstation...")
run_ssh_command("cat > /home/user/boot/10-tests.sh", stdin_data=tests_content)

# 3. Make them executable
print("Making scripts executable...")
run_ssh_command("chmod +x /home/user/boot/09-sync.sh /home/user/boot/10-tests.sh")

print("Files copied successfully!")
