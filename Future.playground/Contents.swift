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

struct User { let avatarURL: NSURL }

func requestUserInfo(userID: String, completion: (Result<User, UserInfoErrorDomain>) -> ())
{
    if (userID == "1234")
    {
        completion(.Success(User(avatarURL: NSURL(string: "nyan_cat.jpeg")!)))
    }
    else
    {
        completion(.Error(.UserDoesNotExist))
    }
}
func downloadImage(URL: NSURL, completion: (Result<UIImage, DownloadImageErrorDomain>) -> ()) { completion(.Success(UIImage(named: URL.absoluteString)!)) }

func loadAvatar(userID: String, completion: (Result<UIImage, ErrorType>) -> ())
{
    requestUserInfo(userID) { requestUserInfoResult in
        switch requestUserInfoResult
        {
            case .Success(let user):
                downloadImage(user.avatarURL) { downloadImageResult in
                    switch downloadImageResult
                    {
                        case .Success(let avatar):
                            completion(.Success(avatar))
                        
                        case .Error(let error):
                            completion(.Error(error))
                    }
                }
            
            case .Error(let error):
                completion(.Error(error))
        }
    }
}

// Success
loadAvatar("1234") { result in
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
loadAvatar("abc") { result in
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