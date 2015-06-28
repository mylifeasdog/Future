//: Playground - noun: a place where people can play

import UIKit

enum Result <T, ErrorType>
{
    case Success(T)
    case Error(ErrorType)
}

enum UserInfoErrorDomain: ErrorType
{
    case UserDoesNotExist
    case UserRequestFailure(reason: String)
    case NetworkRequestFailure(reason: String)
}

enum DownloadImageErrorDomain: ErrorType
{
    case Timeout
    case Unreachable
    case Interrupted
}

struct Future<T, ErrorType>
{
    typealias ResultType = Result<T, ErrorType>
    typealias Completion = ResultType -> ()
    typealias AsyncOperation = Completion -> ()
    
    private let operation: AsyncOperation
    
    init(operation: AsyncOperation)
    {
        self.operation = operation
    }
    
    func start(completion: Completion)
    {
        self.operation() { result in completion(result) }
    }
}

extension Future
{
    func map<U>(f: T -> U) -> Future<U, ErrorType>
    {
        return Future<U, ErrorType>(operation: { completion in
            
            self.start { result in
                
                switch result
                {
                    case .Success(let value):
                        completion(Result.Success(f(value)))
                    case .Error(let error):
                        completion(Result.Error(error))
                }
            }
        })
    }
    
    func andThen<U>(f: T -> Future<U, ErrorType>) -> Future<U, ErrorType>
    {
        return Future<U, ErrorType>(operation: { completion in
            
            self.start { firstFutureResult in
                
                switch firstFutureResult
                {
                    case .Success(let value): f(value).start(completion)
                    case .Error(let error): completion(Result.Error(error))
                }
            }
        })
    }
}

struct User { let avatarURL: NSURL }

func downloadFile(URL: NSURL) -> Future<NSData, UserInfoErrorDomain>
{
    return Future() { completion in
        
        let result: Result<NSData, UserInfoErrorDomain>
        
        // NSData(contentsOfURL: <#T##NSURL#>) not working with given URL in Playground
        if let data = UIImageJPEGRepresentation(UIImage(named: URL.absoluteString)!, 1.0)
        {
            result = Result.Success(data)
        }
        else
        {
            result = Result.Error(.NetworkRequestFailure(reason: "Time out"))
        }
        
        completion(result)
    }
}

func requestUserInfo(userID: String) -> Future<User, UserInfoErrorDomain>
{
    if (userID == "1234")
    {
        return Future() { (completion) in completion(Result.Success(User(avatarURL: NSURL(string: "nyan_cat.jpeg")!))) }
    }
    else
    {
        return Future() { (completion) in completion(Result.Error(.UserDoesNotExist)) }
    }
}


func downloadImage(URL: NSURL) -> Future<UIImage, UserInfoErrorDomain>
{
    return downloadFile(URL).map { UIImage(data: $0)! }
}


func loadAvatar(userID: String) -> Future<UIImage, UserInfoErrorDomain>
{
    return requestUserInfo(userID)
        .map { $0.avatarURL }
        .andThen(downloadImage)
}

// Success
loadAvatar("1234").start() { result in
    switch result
    {
        case .Success(let avatar):
            avatar
        case .Error(let error):
            do
            {
                throw error
            }
            catch UserInfoErrorDomain.UserDoesNotExist
            {
                print("UserDoesNotExist")
            }
            catch UserInfoErrorDomain.UserRequestFailure(let reason)
            {
                print("UserRequestFailure reason : \(reason)")
            }
            catch UserInfoErrorDomain.NetworkRequestFailure(let reason)
            {
                print("NetworkRequestFailure reason : \(reason)")
            }
            catch is DownloadImageErrorDomain
            {
                print("Error while downloading image")
            }
            catch _
            {
                print("There is an error.")
            }
    }
}

// Fail
loadAvatar("abc").start { result in
    switch result
    {
    case .Success(let avatar):
        avatar
    case .Error(let error):
        do
        {
            throw error
        }
        catch UserInfoErrorDomain.UserDoesNotExist
        {
            print("UserDoesNotExist")
        }
        catch UserInfoErrorDomain.UserRequestFailure(let reason)
        {
            print("UserRequestFailure reason : \(reason)")
        }
        catch UserInfoErrorDomain.NetworkRequestFailure(let reason)
        {
            print("NetworkRequestFailure reason : \(reason)")
        }
        catch is DownloadImageErrorDomain
        {
            print("Error while downloading image")
        }
        catch _
        {
            print("There is an error.")
        }
    }
}
