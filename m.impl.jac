impl RepoMapper.repo_clone(repo_url: str, repo_dir: str) {
    report{"response1":"Cloning repository..."};
    Repo.clone_from(repo_url, repo_dir);
    report{"response2":"Repository cloned successfully!"};
}

impl RepoMapper.read_in_chunks(file_path: any, chunk_size: any = 150) {
    with open(file_path, 'r', encoding='utf-8') as f  { 
        chunk = []; 
        for (line_num, line) in enumerate(f, 1) { 
            chunk.append(line); 
            if ((line_num % chunk_size) == 0) {
                yield ''.join(chunk) ;
                chunk = [];
            }
        }
        if chunk {
            yield ''.join(chunk) ;
        }
    }
}

impl CodeAnalyzer.read_files_from_list(file_paths: list[ str ]) -> dict {
    files_dict = {};
    total_files = len(file_paths);
    processed_files = 0;
    for filepath in file_paths {
        relpath = os.path.basename(filepath).replace('.', '_');
        status ='processed';
        with open(filepath, 'r', encoding='utf-8-sig') as f {
            content = f.read();
        }
        files_dict[ relpath ] = [content];
        processed_files += 1;
        if (total_files > 0) {
            percentage = ((processed_files / total_files) * 100);
            rounded_percentage = int(percentage);
            print(f"Progress: {processed_files}/{total_files} ({rounded_percentage}%) {relpath} [{status}]");
        }
    }

    print(f"'\nFound '{len(files_dict)}' readable files:'");
    for path in files_dict { print(f"'  '{path}"); }
    return files_dict;
}

