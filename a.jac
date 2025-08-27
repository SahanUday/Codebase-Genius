#node Service{}
node a {
    has name:str = 'A';
    has owner:str = "";
}
node b {
    has name:str = 'B';
    has owner:str = "";
}
node c {
    has name:str = 'C';
    has owner:str = "";
}


walker main {
    has name:str;
    obj __specs__{
        # static has methods: list = ["get", "post"];
        static has auth: bool = False;
    }


    can greet with `root entry{
        
        here ++>a(owner=self.name);
        here ++>b(owner=self.name);

        node_a = [root --> a];
        node_b = [root --> b];

        if node_a {
            report{"Logic":"I am inside if condition"};
        } else {
            report{"Logic":"I am inside else condition"};
        }

        report{"name":"Hello, " + self.name + " I am Root node"};
        report{"name1":"Hello, " + node_a[-1].owner + " I am Node " + node_a[-1].name};
        report{"name2":"Hello, " + node_b[-1].owner + " I am Node " + node_b[-1].name};
        #report("Hii");
        
        
        visit [-->(`?b: owner==self.name)];
    }
}

walker secondary(main) {
    has name:str;

    obj __specs__{
        # static has methods: list = ["get", "post"];
        static has auth: bool = False;
    }

    can greet2 with `root entry{
        report{"name4": "Hiiiiiiiiiiii"};

    }

    can greet1 with b entry{

        here ++>c(owner=self.name);

        node_c = [here --> c];
        report{"name3":"Hello, " + node_c[0].owner + " I am Node " + node_c[0].name};
    }
}


# with entry {
#     A=a();
#     B=b();
#     C=c();
#     root++>A++>B++>C;
#     quaternary(name="Jone") spawn root;
# }