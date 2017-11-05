import Kitura
import LoggerAPI
import HeliumLogger
import Foundation
import MySQL

// Disable stdout buffering (so log will appear)
setbuf(stdout, nil)

// Init logger
HeliumLogger.use(.info)

// Create connection string (use env variables, if exists)
let env = ProcessInfo.processInfo.environment
var connectionString = MySQLConnectionString(host: "172.17.0.2")
connectionString.port = 3306
connectionString.user = "root"
connectionString.password = "password"
connectionString.database = "game_night"

// Create connection pool
var pool = MySQLConnectionPool(connectionString: connectionString, poolSize: 10, defaultCharset: "utf8mb4")

// Get a connection, insert a dummy activity
do {
    try pool.getConnection() { (connection: MySQLConnectionProtocol) in
      // show all activities
      let selectQuery = "SELECT * FROM activities;"
      let selectResult = try connection.execute(query: selectQuery)
      while case let row? = selectResult.nextResult() {
        print(row)
      }

      // try to insert an activity
      let insertQuery = "INSERT INTO activities " + 
        "(name, genre, description, emoji, min_participants, max_participants) " + 
        "VALUES ('New Activity', 'Puzzle', 'A simple dummy game.', '\u{1F3B2}', '2', '4');"
      let insertResult = try connection.execute(query: insertQuery)
      if insertResult.affectedRows > 0 {
        print("activity was inserted")
      } else {
        print("activity not inserted")
      }

      // try to update an activity
      let updateQuery = "UPDATE activities SET name='Yahtzee', genre='Chance', " +
        "description='Roll the dice!', emoji='\u{1F3B2}', min_participants='2', " +
        "max_participants='9' WHERE id=7;"
      let updateResult = try connection.execute(query: updateQuery)
      if updateResult.affectedRows > 0 {
        print("activity was updated")
      } else {
        print("activity not updated")
      }

      // try to delete an activity
      let deleteQuery = "DELETE FROM activities WHERE id=7"
      let deleteResult = try connection.execute(query: deleteQuery)
      if deleteResult.affectedRows > 0 {
        print("activity was deleted")
      } else {
        print("activity not deleted")
      }
    }
} catch {
    Log.error(error.localizedDescription)
}

// Add an HTTP server and connect it to the router
// Kitura.addHTTPServer(onPort: 8080, with: Router())

// Start the Kitura runloop (this call never returns)
// Kitura.run()
