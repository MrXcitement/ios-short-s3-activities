import Kitura
import LoggerAPI
import HeliumLogger
import Foundation
import ActivitiesService
import MySQL

// Disable stdout buffering (so log will appear)
setbuf(stdout, nil)

// Init logger
HeliumLogger.use(.info)

// Create connection string (use env variables, if exists)
// TODO: Inject environment variables.
let env = ProcessInfo.processInfo.environment
var connectionString = MySQLConnectionString(host: env["MYSQL_HOST"] ?? "172.17.0.2")
connectionString.port = Int(env["MYSQL_PORT"] ?? "3306") ?? 3306
connectionString.user = env["MYSQL_USER"] ?? "root"
connectionString.password = env["MYSQL_PASSWORD"] ?? "password"
connectionString.database = env["MYSQL_DATABASE"] ?? "game_night"

// Create connection pool
var pool = MySQLConnectionPool(connectionString: connectionString, poolSize: 10, defaultCharset: "utf8mb4")

// Create data accessor (uses pool to get connections and access data!)
var dataAccessor = ActivityMySQLDataAccessor(pool: pool)

// Create handlers
let handlers = Handlers(dataAccessor: dataAccessor)

// Create router
let router = Router()

// Setup paths
router.all("/*", middleware: BodyParser())
router.all("/*", middleware: AllRemoteOriginMiddleware())
router.all("/*", middleware: LoggerMiddleware())
router.options("/*", handler: handlers.getOptions)

// GET
router.get("/*", middleware: CheckRequestMiddleware(method: .get))
router.get("/example/:id", handler: handlers.getExample)
router.get("/activities", handler: handlers.getActivities)
router.get("/activities/:id", handler: handlers.getActivities)

// POST
router.post("/*", middleware: CheckRequestMiddleware(method: .post))
router.post("/activities", handler: handlers.postActivity)

// PUT
router.put("/*", middleware: CheckRequestMiddleware(method: .put))
router.put("/activities/:id", handler: handlers.putActivity)

// DELETE
router.delete("/*", middleware: CheckRequestMiddleware(method: .delete))
router.delete("/activities/:id", handler: handlers.deleteActivity)

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8080, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
