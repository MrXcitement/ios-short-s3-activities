import MySQL
import Kitura
import LoggerAPI
import Foundation
import SwiftyJSON

// MARK: - Handlers

public class Handlers {

    // MARK: Properties

    let dataAccessor: ActivityMySQLDataAccessorProtocol

    // MARK: Initializer

    public init(dataAccessor: ActivityMySQLDataAccessorProtocol) {
        self.dataAccessor = dataAccessor
    }

    // MARK: OPTIONS

    public func getOptions(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        response.headers["Access-Control-Allow-Headers"] = "accept, content-type"
        response.headers["Access-Control-Allow-Methods"] = "GET,POST,DELETE,OPTIONS,PUT"
        try response.status(.OK).end()
    }

    // MARK: GET

    public func getExample(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {

        guard let id = request.parameters["id"] else {
            Log.error("id (path parameter) missing")
            try response.send(json: JSON(["message": "id (path parameter) missing"]))
                        .status(.badRequest).end()
            return
        }

        let activities = try dataAccessor.getExample(withID: id)

        if activities == nil {
            try response.status(.notFound).end()
            return
        }

        try response.send(json: activities!.toJSON()).status(.OK).end()
    }

    public func getActivities(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        // TODO: Add implementation.
        // Check for id (if exists).
        // Use data accessor to get activities.
        // Return activities.
    }

    // MARK: POST

    public func postActivity(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        // Check for request body.
        guard let body = request.body, case let .json(json) = body else {
            Log.error("Body contains invalid JSON")
            try response.send(json: JSON(["message": "body is missing JSON or JSON is invalid"]))
                        .status(.badRequest).end()
            return
        }
        // Validate request body has all activity parameters.
        let newActivity = Activity(
            id: nil,
            name: json["name"].string,
            emoji: json["emoji"].string,
            description: json["description"].string,
            genre: json["genre"].string,
            minParticipants: json["min_participants"].int,
            maxParticipants: json["max_participants"].int,
            createdAt: nil, updatedAt: nil)
        
        let missingParameters = newActivity.validateParameters(
            ["name", "emoji", "description", "genre", "minParticipants", "maxParticipants"])

        guard missingParameters.count == 0 else {
            Log.error("Unable to initialize parameters from request body: \(missingParameters).")
            try response.send(json: JSON(["message": "Unable to initialize parameters from request body: \(missingParameters)."]))
                        .status(.badRequest).end()
            return
        }
        // Use data accessor to insert activity.
        guard try dataAccessor.createActivity(newActivity) else {
            try response.status(.notModified).end()
            return
        }
        // Success
        try response.send(json: JSON(["message": "Activity created."])).status(.created).end()

    }

    // MARK: PUT

    public func putActivity(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        // TODO: Add implementation.
        // Check for id.
        // Check for request body.
        // Validate request body has all activity parameters.
        // Use data accessor to update activity.
        // Return success/failure.
    }

    // MARK: DELETE

    public func deleteActivity(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        // TODO: Add implementation.
        // Check for id.
        // Use data accessor to delete activity.
        // Return success/failure.
    }
}
