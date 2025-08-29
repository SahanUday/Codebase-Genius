import streamlit as st
import requests
from typing import List, Dict, Any

st.set_page_config(page_title="Codebase Genius", page_icon="🤖", layout="wide")
BACKEND_URL = "http://localhost:8000/walker/Supervisor"

# ---------- Helpers ----------
def call_jac_supervisor(repo_url: str, repo_path: str) -> Dict[str, Any]:
    payload = {"repo_url": repo_url, "repo_path": repo_path}
    r = requests.post(BACKEND_URL, json=payload, timeout=600)
    r.raise_for_status()
    data = r.json()
    reports = data.get("reports", [])
    chapters = None
    summary = None
    for rep in reports:
        if "overview" in rep:
            summary = rep["overview"]
    for rep in reports:
        if "tutorial" in rep:
            chapters = rep["tutorial"]
            break

    return {"chapters": chapters , "summary": summary}

def normalize_chapters(raw: List[Dict[str, Any]]) -> List[Dict[str, str]]:
    norm = []
    for item in raw:
        ctx = item.get("context", {}) if isinstance(item, dict) else {}
        title = ctx.get("title") or item.get("title") if isinstance(item, dict) else "Untitled"
        content = ctx.get("content") or item.get("content") or ""
        norm.append({"title": title, "content": content})
    return norm

def slugify(title: str) -> str:
    return "".join(ch.lower() if ch.isalnum() else "-" for ch in (title or "")).strip("-")

def get_query_chapter() -> str | None:
    qp = st.query_params.get("chapter")
    if qp is None:
        return None
    if isinstance(qp, list):
        return qp[0] if qp else None
    return qp

def set_query_chapter(slug: str | None):
    if slug is None:
        st.query_params.clear()
    else:
        st.query_params.clear()
        st.query_params["chapter"] = slug

# ---------- Session State ----------
if "current_page" not in st.session_state:
    st.session_state.current_page = "input_page"

if "sidebar_page" not in st.session_state:
    st.session_state.sidebar_page = "Input Page"

# ---------- Sidebar Navigation ----------
st.sidebar.title("📚 Codebase Genius")
if st.sidebar.button("Input Page"):
    st.session_state.sidebar_page = "Input Page"
    st.session_state.current_page = "input_page"
if st.sidebar.button("Tutorial Page"):
    st.session_state.sidebar_page = "Tutorial Page"
    st.session_state.current_page = "tutorial_page"

# ---------- Input Page ----------
if st.session_state.current_page == "input_page":
    st.title("🤖 Codebase Genius")
    st.markdown("##### Codebase to Easy Tutorial with AI")
    st.caption("Enter a public GitHub repository URL and configure options below to generate your tutorial.")

    with st.form("repo_form"):
        repo_url = st.text_input("GitHub Repository URL*", placeholder="https://github.com/user/repo.git")
        raw_repo_path = st.text_input("Local Directory (absolute path preferred)*", placeholder=r"E:\GitHub_Repo\Codebase-Genius\feedback")
        repo_path = raw_repo_path.replace("\\", "\\\\") if raw_repo_path else ""

        col_a, col_b = st.columns([1, 1])
        with col_a:
            submitted = st.form_submit_button("🚀 Generate Tutorial")
        with col_b:
            clear = st.form_submit_button("🧹 Clear Results")

    if clear:
        for k in list(st.session_state.keys()):
            if not k.startswith("s_"):
                st.session_state.pop(k, None)
        set_query_chapter(None)

    if submitted:
        if not repo_url:
            st.error("⚠️ Please provide a GitHub Repository URL")
        elif not repo_path:
            st.error("⚠️ Please provide a local directory path")
        else:
            with st.spinner("Running Supervisor walker on Jac backend…"):
                try:
                    payload = call_jac_supervisor(repo_url, repo_path)
                    chapters = normalize_chapters(payload["chapters"])
                    st.session_state["chapters"] = chapters
                    st.session_state["summary"] = payload.get("summary")
                    st.session_state["repo_url"] = repo_url
                    st.session_state["repo_path"] = repo_path
                    set_query_chapter(slugify("Overview"))
                    st.success("✅ Tutorial generated!")
                    # Automatically navigate to tutorial page
                    st.session_state.current_page = "tutorial_page"
                except requests.HTTPError as e:
                    st.error(f"Backend error: {getattr(e.response, 'status_code', '??')} — {getattr(e.response, 'text', str(e))[:500]}")
                except Exception as e:
                    st.error(f"Failed to contact backend: {e}")

# ---------- Tutorial Display Page ----------
elif st.session_state.current_page == "tutorial_page":
    chapters: List[Dict[str, str]] = st.session_state.get("chapters", [])
    summary: str | None = st.session_state.get("summary")
    repo_url = st.session_state.get("repo_url")
    repo_path = st.session_state.get("repo_path")

    if not chapters:
        st.warning("No tutorial found. Please generate a tutorial first.")
        if st.button("← Go Back to Input Page"):
            st.session_state.current_page = "input_page"
            st.session_state.sidebar_page = "Input Page"
    else:
        # Sidebar chapter navigation
        with st.sidebar:
            st.header("📑 Chapters")
            options_names = ["Overview"] + [c["title"].split(":")[0].strip() for c in chapters]
            options = ["Overview"] + [c["title"] for c in chapters]
            qslug = get_query_chapter()
            if qslug:
                choice_title = next((t for t in options if slugify(t) == qslug), "Overview")
                # Map the full title to its short title for display
                choice_name = options_names[options.index(choice_title)]
                _ = st.radio("Go to Chapter", options_names, index=options_names.index(choice_name), key="sidebar_choice")
            else:
                _ = st.radio("Go to Chapter", options_names, index=0, key="sidebar_choice")
            selected_name = st.session_state.get("sidebar_choice", "Overview")
            # Map the selected short title back to the full title
            selected = options[options_names.index(selected_name)] if selected_name in options_names else "Overview"
            if slugify(selected) != get_query_chapter():
                set_query_chapter(slugify(selected))

        # Main panel
        q = get_query_chapter()
        if q:
            choice = next((t for t in (["Overview"] + [c["title"] for c in chapters]) if slugify(t) == q), "Overview")
        else:
            choice = st.session_state.get("sidebar_choice", "Overview")

        if choice == "Overview":
            st.header("🔎 Overview")
            if repo_url and repo_path:
                st.markdown(f"**Repository:** {repo_url}\n\n**Local Path:** `{repo_path}`")
            if summary:
                st.markdown("---")
                st.markdown(summary)
            else:
                st.warning("No overview summary was returned by the backend for this run.")
            st.markdown("---")
            st.markdown("### Chapters")
            for i, c in enumerate(chapters, start=1):
                if st.button(f"{i}. {c['title']}", key=f"chapter_button_{i}"):
                    set_query_chapter(slugify(c['title']))
        else:
            st.header(choice)
            chapter = next((c for c in chapters if c["title"] == choice), None)
            if chapter:
                st.markdown(chapter["content"])
            else:
                st.warning("Chapter not found.")
            st.divider()
            c1, c2 = st.columns(2)
            # Determine the current index in the options list
            options = ["Overview"] + [c["title"] for c in chapters]
            current_index = options.index(choice) if choice in options else 0
            # Previous Chapter button
            with c1:
                if current_index > 0:
                    prev_title = options[current_index - 1]
                    if st.button("⟵ Previous Chapter"):
                        set_query_chapter(slugify(prev_title))
            # Next Chapter button
            with c2:
                if current_index < len(options) - 1:
                    next_title = options[current_index + 1]
                    if st.button("Next Chapter ⟶"):
                        set_query_chapter(slugify(next_title))