import os

def read_files_from_list(file_paths: list[str]):
    files_dict = {}
    total_files = len(file_paths)
    processed_files = 0

    for filepath in file_paths:
        relpath = os.path.basename(filepath)
        status = "processed"

        try:
            with open(filepath, "r", encoding="utf-8-sig") as f:
                content = f.read()
            files_dict[relpath] = content
        except Exception as e:
            status = f"skipped (error: {e})"

        processed_files += 1
        if total_files > 0:
            percentage = (processed_files / total_files) * 100
            rounded_percentage = int(percentage)
            print(f"\x1b[92mProgress: {processed_files}/{total_files} "
                  f"({rounded_percentage}%) {relpath} [{status}]\x1b[0m")

    print(f"\nFound {len(files_dict)} readable files:")
    for path in files_dict:
        print(f"  {path}")

    return files_dict
