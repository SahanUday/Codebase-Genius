node User {
    has user_id: str= "";
    has user_name: str= "";
}

walker UserWalker {
    has user_id: str= "";
    has user_name: str= "";

    obj __specs__{
        static has auth: bool = False;
    }

    can access with `root entry{
        users = [root -->User];
        #print(users);

        for u in users {
            if u.user_id == self.user_id {
                #print("User already exists!");
                report{"response1":"User already exists!"};
                break;
            } 
        } else {
            here ++> User(user_id=self.user_id, user_name=self.user_name);
            #print("New user created!");
            report{"response2":"New user created!"};
        }
    }
}

# with entry {
#     UserWalker(user_id="002", user_name="Alice") spawn root;
# }