
import from mtllm.llms { Gemini }

glob llm = Gemini(model_name="gemini-2.5-flash");

"""
Generate Country names with their capitals.
output response dictionary format is {
    {"name": "Country Name",
    "capital": "Capital City"}
}
"""
def generate_random_country() -> dict by llm();

with entry {
    country = generate_random_country();
    print(country);
}