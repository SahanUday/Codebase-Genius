"""obtain this chunk of text and summary of get so far and give the response as the new summary of the chunk of text combined with the given summary so far, maximum 150 lines."""
def get_summary(text_chunk: str, summary: str) -> str by llm();

"""Given a cloned GitHub repository path and a project summary, 
    identify and filter out non-essential files. You can use get_all_file_paths tool for getting all file paths in the repository. Also use summary for understanding the project context.
    Return a list of only the meaningful source code files that are crucial for understanding the project's logic and abstractions. Exclude documentationumentation, configuration, test, and dependency files.""" 
def get_filtered_folder_structure(repo_path: str = '.', summary: str = '') -> list by llm(method="ReAct", tools=[get_all_file_paths]);

obj Absts {
    has name: str;
    has description: str;
    has related_files: list[];
}
"""Obtain all_codes and identify new abstractions atleast 5 or 6.
All the Absts objects values output as a String."""
def extract_abstractions(all_codes: dict) -> list[Absts] by llm(method='Reason');

"""Obtain given project abstractions and identify key relationships between the abstractions for understanding best order of abstractions to explain. 
Each relationship should show a from_abstraction, to_abstraction, and a brief label(A brief (a few words) description of the interaction)."""
def get_relationships(abstractions: list) -> list[Rels] by llm(method='Reason');

"""Obtain given the project summary, all abstractions, and their all relationships,
Determine best order to explain this project in a tutorial.
Output the ordered list of abstraction indices"""
def chapter_ordering(summary: str, all_abstractions: list, all_relationships: list) -> list[int] by llm(method="Reason");

obj Cformat {
    has heading: str;
    has highlevel_explanation_section: str;
    has mermaid_diagram_section: str;
}

sem Cformat = "Cformat is a structured format for drafted chapters.";
sem Cformat.heading = "Clear heading of the chapter";
sem Cformat.highlevel_explanation_section = "High-level motivation explaining about the chapter content";
sem Cformat.mermaid_diagram_section = "Mermaid diagrams to illustrate complex concepts' high-level architecture.";

"""Generate drafted chapters for each abstraction in the abstractions_list."""
def chapter_drafting(abstractions_list: list, all_code_snippets: dict) -> list[Cformat] by llm();

obj Chapter {
    has title: str;
    has content: str;
}

sem Chapter = "complete Chapter for the tutorial.";
sem Chapter.title = "Clear and concise title of the chapter.";
sem Chapter.content = "Comprehensive content of the chapter in a cohesive manner including smooth transitions between chapters.";

"""Obtain all_drafted_chapters and generate a beginner friendly complete chapters in Markdown format, including smooth transitions and consistent tone.
"""
def generate_tutorial(all_drafted_chapters: list) -> list[Chapter] by llm(method='Reason');


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