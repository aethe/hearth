//
//  Logger.swift
//  Hearth
//
//  Created by Andrey Ufimcev on 19/01/2020.
//

import Foundation

/// A logger for writing messages to logs.
public final class Logger {
    /// The queue all logging operations are performed on.
    private let queue = DispatchQueue(label: "hearth-logger", qos: .utility)

    /// An array of associated logs.
    private var logs = [(log: Log, levels: Filter<Level>, tags: Filter<Tag>)]()

    /// Creates a new logger.
    public init() { }

    /// Writes a new message to the associated logs.
    ///
    /// - Parameter message: The message to write.
    public func write(_ message: Message) {
        queue.sync {
            logs
                .filter { $0.levels.test(message.level) && $0.tags.test(message.tags) }
                .map { $0.log }
                .forEach { $0.write(message) }
        }
    }

    /// Writes a new message to the associated logs.
    ///
    /// - Parameters:
    ///   - text: The text of the message.
    ///   - level: The level of the message. Defaults to `.info`.
    ///   - tags: The tags of the message. Defaults to an empty array.
    ///   - file: The file where the write function was called from. Defaults to the current file.
    ///   - line: The line where the write function was called from. Defaults to the current line.
    public func write(_ text: String, level: Level = .info, tags: [Tag] = [], file: String = #file, line: Int = #line) {
        write(Message(text: text, level: level, tags: tags, file: file, line: line))
    }

    /// Writes a new message to the associated logs.
    ///
    /// - Parameters:
    ///   - text: The text of the message.
    ///   - level: The level of the message. Defaults to `.info`.
    ///   - tags: The tags of the message.
    ///   - file: The file where the write function was called from. Defaults to the current file.
    ///   - line: The line where the write function was called from. Defaults to the current line.
    public func write(_ text: String, level: Level = .info, tags: Tag..., file: String = #file, line: Int = #line) {
        write(text, level: level, tags: tags, file: file, line: line)
    }

    /// Attaches the logger to a new log.
    ///
    /// - Parameters:
    ///   - log: The log to add.
    ///   - levels: The levels to filter messages by before writing to the log. Defaults to `.all`.
    ///   - tags: The tags to filter the messages by before writing to the log. Defaults to `.all`.
    ///   - environment: The environment in which the logger should be attached to the log. Defaults to `.any`.
    public func attach(to log: Log, levels: Filter<Level> = .all, tags: Filter<Tag> = .all, environment: Environment = .any) {
        queue.sync {
            environment.execute {
                logs.append((log, levels, tags))
            }
        }
    }

    /// Detaches the logger from a specific log.
    ///
    /// - Parameter log: The log to remove.
    public func detach(from log: Log) {
        queue.sync {
            logs.removeAll { $0.log === log }
        }
    }

    /// Detaches the logger from all logs.
    public func detach() {
        queue.sync {
            logs.removeAll()
        }
    }
}
