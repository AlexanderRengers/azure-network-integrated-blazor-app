using Azure.Identity;
using Microsoft.Data.SqlClient;
using System.Collections.Generic;
using System.Threading.Tasks;

public class CustomerService
{
    private readonly string _connectionString;

    public CustomerService(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<List<Customer>> GetTopCustomersAsync()
    {
        var customers = new List<Customer>();

        var tokenCredential = new DefaultAzureCredential();
        var token = await tokenCredential.GetTokenAsync(new Azure.Core.TokenRequestContext(new[] { "https://database.windows.net/.default" }));

        using var connection = new SqlConnection(_connectionString);
        connection.AccessToken = token.Token;

        var query = "SELECT TOP 10 CustomerID, FirstName, LastName, EmailAddress FROM SalesLT.Customer ORDER BY CustomerID";
        var command = new SqlCommand(query, connection);

        await connection.OpenAsync();
        using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            customers.Add(new Customer
            {
                CustomerID = reader.GetInt32(0),
                FirstName = reader.GetString(1),
                LastName = reader.GetString(2),
                EmailAddress = reader.GetString(3)
            });
        }

        return customers;
    }
}

public class Customer
{
    public int CustomerID { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string EmailAddress { get; set; }
    // Add other properties as needed
}
