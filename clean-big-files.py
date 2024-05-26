import os
from subprocess import run

# 50MB
max_size = 50 * 1024 * 1024

def list_large_files(repo_path, max_size):
    os.chdir(repo_path)
    command_list=['git', 'ls-tree', '-r', '--long', 'HEAD']
    result = run(command_list, capture_output=True, text=True)
    files = result.stdout.splitlines()
    
    large_files = []
    for line in files:
        parts = line.split()
        size = int(parts[3])
        file_path = parts[4]
        if size > size_limit:
            large_files.append(file_path)
    
    return large_files

def remove_large_files(repo_path, large_files):
    command_list=['git', 'filter-repo', '--path', file_path, '--invert-paths']
    for file_path in large_files:
        run(command_list)

repo_path = '.'
size_limit = 50 * 1024 * 1024  # 50 MB
large_files = list_large_files(repo_path, size_limit)

if large_files:
    print(f"Found large files: {large_files}")
    # remove_large_files(repo_path, large_files)
    #print("Large files removed successfully.")
else:
    print("No large files found.")