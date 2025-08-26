node a {has name:str = 'A';}
node b {has name:str = 'B';}
node c {has name:str = 'C';}

walker main {
    has name:str;

    can greet with `root entry{
        #print("Hello, " + self.name + " I am Root node");
        visit[-->];
    }
}

walker secondary(main) {
    has name:str;

    can greet1 with a entry{
        #print("Hello, " + self.name + " I am Node " + here.name);
        here.name = "Name Change";
        visit[-->];
    }
}

walker tertiary(secondary) {
    has name:str;

    can greet2 with b entry{
        #print("Hello, " + self.name + " I am Node " + here.name);
        visit[-->];
    }
}

walker quaternary(tertiary) {
    has name:str;

    can greet3 with c entry{
        #print("Hello, " + self.name + " I am Node " + here.name);
        print(A.name);
    }
}

with entry {
    A=a();
    B=b();
    C=c();
    root++>A++>B++>C;
    quaternary(name="Jone") spawn root;
}