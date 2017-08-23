import MySQL

// MARK: - ActivityMySQLDataAccessorProtocol

public protocol ActivityMySQLDataAccessorProtocol {
    func createActivity(_ activity: Activity) throws -> Bool
    func updateActivity(_ activity: Activity) throws -> Bool
    func deleteActivity(withID id: String) throws -> Bool
    func getActivities(withID id: String) throws -> [Activity]?
    func getActivities(pageSize: UInt, pageNumber: UInt64) throws -> [Activity]?
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
        let insertQuery = MySQLQueryBuilder()
                .insert(data: activity.toMySQLRow(), table: "activities")

        let result = try execute(builder: insertQuery)
        return result.affectedRows > 0
    }

    public func updateActivity(_ activity: Activity) throws -> Bool {
        let updateQuery = MySQLQueryBuilder()
                .update(data: activity.toMySQLRow(), table: "activities")
                .wheres(statement: "WHERE Id=?", parameters: "\(activity.id!)")

        let result = try execute(builder: updateQuery)
        return result.affectedRows > 0
    }

    public func deleteActivity(withID id: String) throws -> Bool {
        let deleteQuery = MySQLQueryBuilder()
                .delete(fromTable: "activities")
                .wheres(statement: "WHERE Id=?", parameters: "\(id)")

        let result = try execute(builder: deleteQuery)
        return result.affectedRows > 0
    }

    public func getActivities(withID id: String) throws -> [Activity]? {
        let select = MySQLQueryBuilder()
            .select(fields: ["id", "name", "emoji", "description", "genre",
            "min_participants", "max_participants", "created_at", "updated_at"], table: "activities")
            .wheres(statement:"WHERE Id=?", parameters: id)

        let result = try execute(builder: select)
        let activities = result.toActivities()
        return (activities.count == 0) ? nil : activities
    }

    public func getActivities(pageSize: UInt = 10, pageNumber: UInt64 = 0) throws -> [Activity]? {
        let selectBuilder = MySQLQueryBuilder()
            .select(fields: ["id", "name", "emoji", "description", "genre",
            "min_participants", "max_participants", "created_at", "updated_at"], table: "activities")

        let result = try execute(builder: selectBuilder)
        let offset = (UInt64(pageSize) / pageNumber - 1)
        if offset > 0 {
            result.seek(offset: Int64(offset))
        }

        let activities = result.toActivities(pageSize: pageSize)
        return (activities.count == 0) ? nil : activities
    }

    // MARK: Utility

    func execute(builder: MySQLQueryBuilder) throws -> MySQLResultProtocol {
        let connection = try pool.getConnection()
        defer { pool.releaseConnection(connection!) }

        return try connection!.execute(builder: builder)
    }
}
