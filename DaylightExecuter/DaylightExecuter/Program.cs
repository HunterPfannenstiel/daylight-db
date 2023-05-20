using DbUp;
using System.Reflection;
using DbUp.Helpers;

public class Program
{
	public static void Main(string[] args)
	{
		string connectionString;
		using(StreamReader reader = new("./Connection.txt"))
		{
			connectionString = reader.ReadLine();
		}

		var upgrader = DeployChanges.To
			.PostgresqlDatabase(connectionString)
			.WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly())
			.WithVariablesDisabled()
			.JournalTo(new NullJournal())
			.LogToConsole()
			.Build();

		var result = upgrader.PerformUpgrade();

		if (!result.Successful) Console.WriteLine(result.Error);
		else Console.WriteLine("Success!");
		Console.Write("Press enter to close");
		Console.ReadLine();
	}
}