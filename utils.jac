"""obtain this chunk of text and summary of get so far and give the response as the new summary of the chunk of text combined with the given summary so far, maximum 150 lines."""
def get_summary(text_chunk: str, summary: str) -> str by llm();

"""Given a cloned GitHub repository path and a project summary, 
    identify and filter out non-essential files. You can use get_all_file_paths tool for getting all file paths in the repository. Also use summary for understanding the project context.
    Return a list of only the meaningful source code files that are crucial for understanding the project's logic and abstractions. Exclude documentationumentation, configuration, test, and dependency files.""" 
def get_filtered_folder_structure(repo_path: str = '.', summary: str = '') -> list by llm(method="ReAct", tools=[get_all_file_paths]);


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


"""Obtain all_drafted_chapters and generate a beginner friendly complete chapters in Markdown format, including smooth transitions and consistent tone.
"""
def generate_tutorial(all_drafted_chapters: list) -> list[Chapter] by llm(method='Reason');
