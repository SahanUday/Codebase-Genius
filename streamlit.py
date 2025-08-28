import streamlit as st

st.set_page_config(page_title="Codebase Genius", page_icon="📘", layout="centered")

st.title("📘 Codebase Genius")

st.markdown("Enter the GitHub repository URL and the local folder where files should be stored.")

# Form layout
with st.form("repo_form"):
    repo_url = st.text_input("GitHub Repository URL*", placeholder="https://github.com/user/repo")
    output_dir = st.text_input("Local Directory*", placeholder="output")

    submitted = st.form_submit_button("🚀 Start")

if submitted:
    if not repo_url:
        st.error("⚠️ Please provide a GitHub Repository URL")
    elif not output_dir:
        st.error("⚠️ Please provide a local directory path")
    else:
        st.success("✅ Repository details received. Processing...")
        st.write("**GitHub Repository:**", repo_url)
        st.write("**Local Directory:**", output_dir)

        # 👉 Here you can run your clone / walker logic
        # Example: Repo.clone_from(repo_url, output_dir)
