# function dotnet -w dotnet
    if test "$argv[1]" = 'new' && test "$argv[2]" = 'console' && test "$argv[3]" = '-o'
        command dotnet new console -o $argv[4] && cd $argv[4] && echo "namespace $argv[4] {
    class Program {
        static void Main(string[] args) {
            
        }
    }
}" > Program.cs && nvim Program.cs
    else
        command dotnet $argv
    end
# end
