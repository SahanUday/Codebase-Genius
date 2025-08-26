impl main.repo_clone{
        print("Cloning repository...");
        #Repo.clone_from(self.repo_url, Path(self.repo_dir));
        print('Repository cloned successfully!');
        visit[-->];
}

impl main.get_summ{

        file_path = Path(self.repo_dir+"\README.md");
        for (i, chunk_text) in enumerate(read_in_chunks(file_path, 200), 1) { 
            print("Getting summary...");
            response = send_to_gemini(chunk_text, here.summary);
            here.summary = response;
        }
}

impl get_folder_structure.access{
    top_layer: dict ={};
    print("Accessing folder structure...");
    repo_path = Path(self.repo_dir);
    # top_layer = filter_toplayer_files_folders(repo_path,here.summary);
    # print(top_layer);
    here.folder_structure = get_filtered_folder_structure(repo_path,here.summary);
    print("Folder structure accessed successfully!");
    visit[-->];
}

impl get_codebase.get_c {
        print("Accessing codebase...");
        here.code_base = read_files_from_list(repo.folder_structure);
        print("Codebase accessed successfully!");
        visit[-->];
}

impl IdentifyAbstractions.identify {
        # for (file_name,file_content) in code.code_base.items() {
        #     print("Identifying abstractions...");
        #     updated_abstractions = extract_abstractions(file_content, file_name,here.abstractions);
        #     here.abstractions = updated_abstractions;
        #     print(here.abstractions);
        # }
        print("Identifying abstractions...");
        updated_abstractions = extract_abstractions(code.code_base);
        here.abstractions = updated_abstractions;
        print(here.abstractions);
        # print("Abstractions identified successfully!");
        # print("Abstractions:", here.abstractions);
        visit[-->];
}

impl AnalyzeRelationships.analyze {
        print("Analyzing relationships...");
        here.relationships = get_relationships(abst.abstractions);
        print("Relationships analyzed successfully!");
        visit[-->];
}

impl DocGenerator.ordering {
        print("Getting Order of the Chapters for documentation...");
        here.chapter_order = chapter_ordering(repo.summary, abst.abstractions, rel.relationships);
        print("Chapter order obtained successfully!");

        #ordered_abstractions = [abst.abstractions[i] for i in here.chapter_order];
        ordered_abstractions = [];
        for i in here.chapter_order {
            ordered_abstractions.append(abst.abstractions[i]);
        }
        # print(ordered_abstractions);

        # for abs in ordered_abstractions {
        #     code_list = abs.related_files;
        #     codes = {key: code.code_base[key] for key in code_list};

        #     if len(here.drafted_chapters) > 0 {
        #         previous_chapter = here.drafted_chapters[-1];
        #     } else {
        #         previous_chapter = "No previous chapter, this is the first chapter.";
        #     }

        #     if ordered_abstractions.index(abs) < len(ordered_abstractions) - 1 {
        #         next_chapter = ordered_abstractions[ordered_abstractions.index(abs) + 1];
        #     } else {
        #         next_chapter = "No next chapter, this is the last chapter.";
        #     }

        #     print("Generating drafted chapters...");
        #     here.drafted_chapters.append(chapter_drafting([abs], codes, [previous_chapter], [next_chapter]));
        # }
        # print("Drafted chapters generated successfully!");

        print("Generating drafted chapters...");
        here.drafted_chapters= chapter_drafting(ordered_abstractions, code.code_base);

        visit[-->];
}

impl TutorialGenerator.generate {
    print("Generating tutorial...");
    here.chapters = generate_tutorial(doc.drafted_chapters);
    print("Tutorial generated successfully!");
}

impl read_files_from_list(file_paths: list[ str ]) -> dict {
    files_dict = {};
    total_files = len(file_paths);
    processed_files = 0;
    for filepath in file_paths {
        relpath = os.path.basename(filepath);
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

impl get_top_level_structure_dict(repo_path: str) -> dict {
    repo_path = Path(repo_path).resolve();
    structure = {'folders' : [] , 'files' : [] };
    for item in sorted(repo_path.iterdir()) { if item.is_dir() {
        structure[ 'folders' ].append((item.name));
    } else {
        structure[ 'files' ].append(item.name);
    }  }
    return structure;
}

impl get_all_file_paths(repo_path: str) -> list {
    repo_path = Path(repo_path);
    all_files = [];
    if (repo_path.exists() and repo_path.is_dir() ) {
        for file_path in repo_path.rglob('*') { 
            if file_path.is_file() {
                all_files.append(str(file_path.resolve()));
            }
        }
    }
    return all_files;
}

impl read_in_chunks(file_path: any, chunk_size: any = 150) {
    with open(file_path, 'r', encoding='utf-8') as f  { chunk = []; for (line_num, line) in enumerate(f, 1) { chunk.append(line); if ((line_num % chunk_size) == 0) {
        yield ''.join(chunk) ;;
        chunk = [];
    } }  if chunk {
        yield ''.join(chunk) ;;
    } }
}