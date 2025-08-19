import os

def read_files_from_list(file_paths):
    files_dict = {}
    total_files = len(file_paths)
    processed_files = 0

    for filepath in file_paths:
        relpath = os.path.basename(filepath)  # You can change this to relative path if needed
        status = "processed"

        try:
            with open(filepath, "r", encoding="utf-8-sig") as f:
                content = f.read()
            files_dict[relpath] = content
        except Exception as e:
            print(f"Warning: Could not read file {filepath}: {e}")
            status = "skipped (read error)"

        processed_files += 1

        # Print progress
        if total_files > 0:
            percentage = (processed_files / total_files) * 100
            rounded_percentage = int(percentage)
            print(f"\033[92mProgress: {processed_files}/{total_files} "
                  f"({rounded_percentage}%) {relpath} [{status}]\033[0m")

    # Final summary
    print(f"\nFound {len(files_dict)} readable files:")
    for path in files_dict:
        print(f"  {path}")

    return {"files": files_dict}


# Example usage
if __name__ == "__main__":
    file_paths = [
        'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App\\lib\\main.dart',
        'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App\\lib\\screens\\geofencing_page.dart',
        'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App\\lib\\screens\\home_screen.dart',
        'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App\\lib\\screens\\login_screen.dart',
        'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App\\lib\\screens\\scheduler_page.dart',
        'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App\\lib\\screens\\smart_control_page.dart',
        'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App\\lib\\widgets\\bottom_nav_bar.dart'
    ]
    result = read_files_from_list(file_paths)
    print(result)
