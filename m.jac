#import from git { Repo }
import from pathlib { Path }
import from mtllm.llms { Gemini }
import os;
import from utils { get_summary, get_filtered_folder_structure, extract_abstractions, get_relationships, chapter_ordering, generate_tutorial }

glob llm = Gemini(model_name="gemini-2.5-flash");

obj Absts {
    has name: str;
    has description: str;
    has related_files: list[];
}

obj Cformat {
    has heading: str;
    has highlevel_explanation_section: str;
    has mermaid_diagram_section: str;
}

sem Cformat = "Cformat is a structured format for drafted chapters.";
sem Cformat.heading = "Clear heading of the chapter";
sem Cformat.highlevel_explanation_section = "High-level motivation explaining about the chapter content";
sem Cformat.mermaid_diagram_section = "Mermaid diagrams to illustrate complex concepts' high-level architecture.";


obj Chapter {
    has title: str;
    has content: str;
}

sem Chapter = "complete Chapter for the tutorial.";
sem Chapter.title = "Clear and concise title of the chapter.";
sem Chapter.content = "Comprehensive content of the chapter in a cohesive manner including smooth transitions between chapters.";



node RepoMapper {
    has repo_url: str= "";
    has folder_structure: list[str]=[];
    has summary: str= "";

    def repo_clone{
        print("Cloning repository...");
        #Repo.clone_from(self.repo_url, Path(self.repo_dir));
        print('Repository cloned successfully!');
    }

    def read_in_chunks(file_path: any, chunk_size: any = 150);

    def get_all_file_paths(repo_path: str) -> list();



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


    can repo_clone with `root entry{
        DocGenie_nodes = [root -->DocGenie];

        for Doc in DocGenie_nodes {
            if Doc.repo_url == self.repo_url {
                #report{Doc.chapters};
                report{"response1":"Give existing Tutorial!"};
                disengage;

            } 
        } else {
            ##########################################
            here ++> DocGenie(repo_url=self.repo_url);
            ##########################################

            report{"response2":"Creating new RepoMapper node!"};
            # here ++> RepoMapper(repo_url=self.repo_url_);
            # RepoMapper_nodes = [root --> RepoMapper];
            # Repo = RepoMapper_nodes[-1];

            # chunks = Repo.read_in_chunks(file_path: any, chunk_size: any = 150);
            # Repo.summary = Repo.get_summary(chunks, Repo.summary);

            # Repo.folder_structure = Repo.get_filtered_folder_structure(repo_path: self.repo_path, summary: Repo.summary);

        }
    }
}

walker Analyzer(Supervisor) {

    can analyze_code with `root entry{
        report{"response3":"Analyzing code..."};
    }
}

walker Documenter(Analyzer) {

    can generate_docs with `root entry{
        report{"response4":"Generating documentation..."};
    }
}

