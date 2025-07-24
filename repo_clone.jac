import from git { Repo }

walker main {
    has repo_url: str;
    has local_dir: str;

    can clone_repo with `root entry {
        #repo_url = 'https://github.com/SahanUday/Forest-Fire-Predictor.git';
        #local_dir = 'D:\\MORA\\Project\\Jac\\Jac-Forest-Fire';
        Repo.clone_from(self.repo_url, self.local_dir);
        print('Repository cloned successfully!');
    }
}

with entry {
    main(repo_url = 'https://github.com/SahanUday/Forest-Fire-Predictor.git',local_dir = 'D:\\MORA\\Project\\Jac\\Jac-Forest-Fire') spawn root;
}