impl RepoMapper.repo_clone(repo_url: str, repo_dir: str) {
    report{"response1":"Cloning repository..."};
    #Repo.clone_from(repo_url, Path(repo_dir));
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

# Walkers

# impl Supervisor.repo_clone{
#     DocGenie_nodes = [root -->DocGenie];

#     for Doc in DocGenie_nodes {
#         if Doc.repo_url == self.repo_url {
#             #report{Doc.chapters};
#             report{"response1":"Give existing Tutorial!"};
#             disengage;

#         } 
#     } else {

#         here ++> RepoMapper(repo_url=self.repo_url);
#         RepoMapper_nodes = [root --> RepoMapper];
#         Repo = RepoMapper_nodes[-1];

#         file_directory = Path(self.repo_path+"\README.md");
#         for (i, chunk_text) in enumerate(Repo.read_in_chunks(file_directory, 200), 1) { 
#             report{"response7":"Getting summary..."};
#             response = get_summary(chunk_text, Repo.summary);
#             Repo.summary = response;
#         }

#         Repo.folder_structure = get_filtered_folder_structure(Path(self.repo_path), Repo.summary);

#         report{"response5":Repo.folder_structure};
#         report{"response6":Repo.summary};

#     }
# }