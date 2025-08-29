#nodes

impl RepoMapper.repo_clone(repo_url: str, repo_dir: str) {
    print("Cloning repository...");
    Repo.clone_from(repo_url, repo_dir);
    print("Repository cloned successfully!");
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

# walker

impl Supervisor.start {
    ExDocGenie_nodes = [root --> (`?DocGenie: saved_repo_url==self.repo_url)];
    if ExDocGenie_nodes {
        report{"overview":ExDocGenie_nodes[0].overview};
        report{"tutorial":ExDocGenie_nodes[0].chapters};
        disengage;
    } else {
        here ++> RepoMapper();
        RepoMapper_nodes = [root --> RepoMapper];
        Repo = RepoMapper_nodes[-1];

        Repo.repo_clone(self.repo_url, self.repo_path);

        file_directory = Path(self.repo_path+"\README.md");
        if file_directory.exists() {
            for (i, chunk_text) in enumerate(Repo.read_in_chunks(file_directory, 200), 1) {
                print("Getting summary...");
                response = get_summary(chunk_text, Repo.summary);
                Repo.summary = response;
            }
        } else {
            Repo.summary = "No README.md found in the repository.";
        }

        print("Filtering folder structure...");
        Repo.folder_structure = get_filtered_folder_structure(Path(self.repo_path), Repo.summary);

        here ++> CodeAnalyzer();
        CodeAnalyzer_nodes = [root --> CodeAnalyzer];
        Code = CodeAnalyzer_nodes[-1];

        Code.code_base = Code.read_files_from_list(Repo.folder_structure);

        print("Extracting abstractions...");
        Code.abstractions = extract_abstractions(Code.code_base);

        print("Identifying relationships...");
        Code.relationships = get_relationships(Code.abstractions);

        print("Determining chapter order...");
        Code.chapter_order = chapter_ordering(Repo.summary, Code.abstractions, Code.relationships);

        here ++> DocGenie();
        DocGenie_nodes = [root --> DocGenie];
        Doc = DocGenie_nodes[-1];

        Doc.saved_repo_url = self.repo_url;
        
        print("Chapters drafting...");
        Doc.drafted_chapters = chapter_drafting(Code.abstractions, Code.code_base);

        print("Generating overview...");
        Doc.overview = generate_overview(Code.abstractions, Code.relationships);
        report{"overview":Doc.overview};

        print("Tutorial generating...");
        Doc.chapters = generate_tutorial(Doc.drafted_chapters);
        report{"tutorial":Doc.chapters};
    }
}