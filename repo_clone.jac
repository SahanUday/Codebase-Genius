import from git { Repo }

walker main {
    can clone_repo with `root entry {
        repo_url = 'https://github.com/SahanUday/Forest-Fire-Predictor.git';
        local_dir = 'D:\\MORA\\Project\\Jac\\Jac-Forest-Fire';
        Repo.clone_from(repo_url, local_dir);
        print('Repository cloned successfully!');
    }
}

with entry {
    main() spawn root;
}