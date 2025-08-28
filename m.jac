#import from git { Repo }
import from pathlib { Path }
import from mtllm.llms { Gemini }
import os;
import from utils { get_summary,get_filtered_folder_structure,extract_abstractions,get_relationships,chapter_ordering,chapter_drafting,generate_tutorial }


node RepoMapper {
    has repo_url: str= "";
    has folder_structure: list[str]=[];
    has summary: str= "";

    # def repo_clone(repo_url: str, repo_dir: str);

    def read_in_chunks(file_path: any, chunk_size: any = 150);

}

node CodeAnalyzer {
    has code_base: dict = {};
    has abstractions: list = [];
    has relationships: list = [];
    has chapter_order: list = [];

    def read_files_from_list(file_paths: list[ str ]) -> dict();

}

node DocGenie {
    has repo_url: str= "";
    has drafted_chapters: list = [];
    has chapters: list = [];
}

walker Supervisor {
    has repo_url: str= "";
    has repo_path: str= "";

    obj __specs__{
        static has auth: bool = False;
    }

    #can repo_clone with `root entry;


    can repo_clone with `root entry{
        DocGenie_nodes = [root -->DocGenie];

        for Doc in DocGenie_nodes {
            if Doc.repo_url == self.repo_url {
                #report{Doc.chapters};
                report{"response1":"Give existing Tutorial!"};
                disengage;

            } 
        } else {

            here ++> RepoMapper(repo_url=self.repo_url);
            RepoMapper_nodes = [root --> RepoMapper];
            Repo = RepoMapper_nodes[-1];

            file_directory = Path(self.repo_path+"\README.md");
            for (i, chunk_text) in enumerate(Repo.read_in_chunks(file_directory, 200), 1) { 
                report{"response7":"Getting summary..."};
                response = get_summary(chunk_text, Repo.summary);
                Repo.summary = response;
            }

            Repo.folder_structure = get_filtered_folder_structure(Path(self.repo_path), Repo.summary);

            report{"response5":Repo.folder_structure};
            report{"response6":Repo.summary};

            here ++> CodeAnalyzer();
            CodeAnalyzer_nodes = [root --> CodeAnalyzer];
            Code = CodeAnalyzer_nodes[-1];

            Code.code_base = Code.read_files_from_list(Repo.folder_structure);
            report{"response2":Code.code_base};

            Code.abstractions = extract_abstractions(Code.code_base);
            report{"response8":Code.abstractions};

            Code.relationships = get_relationships(Code.abstractions);
            report{"response9":Code.relationships};

            Code.chapter_order = chapter_ordering(Repo.summary, Code.abstractions, Code.relationships);
            report{"response10":Code.chapter_order};

            here ++> DocGenie();
            DocGenie_nodes = [root --> DocGenie];
            Doc = DocGenie_nodes[-1];

            Doc.repo_url = self.repo_url;
            
            Doc.drafted_chapters = chapter_drafting(Code.abstractions, Code.code_base);
            report{"response4":Doc.drafted_chapters};

            Doc.chapters = generate_tutorial(Doc.drafted_chapters);
            report{"response16":Doc.chapters};
        }
    }
}

walker Analyzer(Supervisor) {

    can analyze_code with `root entry{
        #report{"response3":"Analyzing code..."};

        # here ++> CodeAnalyzer();
        # CodeAnalyzer_nodes = [root --> CodeAnalyzer];
        # Code = CodeAnalyzer_nodes[-1];

        # Code.code_base = Code.read_files_from_list(Repo.folder_structure);
        # report{"response2":Code.code_base};

    }
}

walker Documenter(Analyzer) {

    can generate_docs with `root entry{
        report{"response15":"Generating documentation..."};
    }
}


# with entry {
#     Documenter(repo_path="E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App") spawn root;

# }