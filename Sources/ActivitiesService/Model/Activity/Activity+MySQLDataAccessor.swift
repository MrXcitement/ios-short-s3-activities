import MySQL

// MARK: - ActivityMySQLDataAccessorProtocol

public protocol ActivityMySQLDataAccessorProtocol {
    func createActivity(_ activity: Activity) throws -> Bool
    func updateActivity(_ activity: Activity) throws -> Bool
    func deleteActivity(withID id: String) throws -> Bool
    func getActivities(withID id: String) throws -> [Activity]?
    func getActivities() throws -> [Activity]?
    func getExample(withID id: String) throws -> [Activity]?
}

// MARK: - ActivityMySQLDataAccessor: ActivityMySQLDataAccessorProtocol

public class ActivityMySQLDataAccessor: ActivityMySQLDataAccessorProtocol {

    // MARK: Properties

    let pool: MySQLConnectionPoolProtocol

    // MARK: Initializer

    public init(pool: MySQLConnectionPoolProtocol) {
        self.pool = pool
    }

    // MARK: Queries

    public func createActivity(_ activity: Activity) throws -> Bool {
        // Execute insert query.
        let insertQuery = MySQLQueryBuilder()
            .insert(data: activity.toMySQLRow(), table: "activities")
        let result = try execute(builder: insertQuery)
        return result.affectedRows > 0
    }

    public func updateActivity(_ activity: Activity) throws -> Bool {
        // TODO: Add implementation.
        // Execute update query (for specific id).
        return false
    }

    public func deleteActivity(withID id: String) throws -> Bool {
        // TODO: Add implementation.
        // Execute delete query (for specific id).
        return false
    }

    public func getExample(withID id: String) throws -> [Activity]? {
        let select = MySQLQueryBuilder()
                        .select(fields: ["name"], table: "activities")
                        .wheres(statement:"Id=?", parameters: id)

        let result = try execute(builder: select)
        let activities = result.toActivities()
        return (activities.count == 0) ? nil : activities
    }

    public func getActivities(withID id: String) throws -> [Activity]? {
        // Execute select query (for specific id).
        let fields = ["id", "name", "emoji", "description", "genre", "min_participants", "max_participants", "created_at", "updated_at"]
        let select = MySQLQueryBuilder()
                        .select(fields: fields, table: "activities")
                        .wheres(statement:"Id=?", parameters: id)

        let result = try execute(builder: select)
        let activities = result.toActivities()
        return (activities.count == 0) ? nil : activities
    }

    public func getActivities() throws -> [Activity]? {
        // Execute select query (get all activities).
        let fields = ["id", "name", "emoji", "description", "genre", "min_participants", "max_participants", "created_at", "updated_at"]
        let select = MySQLQueryBuilder()
                        .select(fields: fields, table: "activities")

        let result = try execute(builder: select)
        let activities = result.toActivities()
        return (activities.count == 0) ? nil : activities
    }

    // MARK: Utility

    func execute(builder: MySQLQueryBuilder) throws -> MySQLResultProtocol {
        let connection = try pool.getConnection()
        defer { pool.releaseConnection(connection!) }

        return try connection!.execute(builder: builder)
    }
}
