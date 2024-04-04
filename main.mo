import TrieMap "mo:base/TrieMap";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Error "mo:base/Error";

 actor  {
  let dfault : AccessLevel = #ADMIN;
  type User = {
    principleId :Principal;
    name : Text;
    email : Text;
    age : Nat;
    accessLevel : AccessLevel;
    timestamp : Time.Time;
  };
  type NewUser = {
    name : Text;
    email : Text;
    age : Nat;
    accessLevel : AccessLevel;
  };
  let default_user : User = {
    principleId = Principal.fromText("2vxsx-fae");
    name = "";
    email = "";
    age = 0;
    accessLevel = dfault;
    timestamp = Time.now();
  };
  type AccessLevel = {
    #ADMIN;
    #USER;
    #GUEST;
  };
  var users = TrieMap.TrieMap<Principal, User>(Principal.equal, Principal.hash);
  stable var usersEntries: [(Principal, User)] = [];
  system func preupgrade() {
    usersEntries := Iter.toArray(users.entries());
  };
  system func postupgrade() {
    users := TrieMap.fromEntries(usersEntries.vals(), Principal.equal, Principal.hash);
  };
  public shared ({caller}) func createUser(args : NewUser) : async Result.Result<Text, Text> {
    try {
      if(user_has_account(caller)) {
        Debug.trap("The user is already registered");
        return #err("The user is already registered");
      };
      // creating the user account
    let new_user : User = {
      principleId = caller;
      name = args.name;
      email = args.email;
      age = args.age;
      accessLevel = args.accessLevel;
      timestamp = Time.now();
  };
      users.put(caller, new_user);
      return #ok("User created successfuly");
    } catch e {
      return #err(Error.message(e))
    }
  };
  func user_has_account(user_id: Principal): Bool {
    if (Principal.isAnonymous(user_id)) { 
      Debug.trap("Annonymous id.")
    };
    // checking if the caller have already registered to the application
    let option_user: ?User = users.get(user_id);
    return Option.isSome(option_user);
  };
  public shared func get_user_account(user_id: Principal): async User {
    if(not user_has_account(user_id)) {
      Debug.trap("Please start by creating an account as a user")
    };
    let option_user: ?User = users.get(user_id);
    let user: User = Option.get(option_user, default_user);
    return user;
  };
  public shared query func getUser(principleId : Principal) : async Result.Result<User, Text> {
    switch (users.get(principleId)) {
      case (null) {
        return #err("User not found");
      };
      case (?user) {
        return #ok(user);
      };
    };
  };
  public shared ({caller}) func updateUser(args : User) : async () {
    if(not user_has_account(caller)) {
      Debug.trap("Please start by creating an account as a user")
    };
    users.put(args.principleId, args);
  };
  public shared func deleteUser(id : Principal) : async () {
    users.delete(id);
  };
  public shared query func getAllUsers() : async [User] {
    Iter.toArray(users.vals());
  };
  public shared query func getUserAccessLevel(id:Principal) : async Result.Result<Text, Text> {
    switch (users.get(id)) {
      case (null) {
        return #err("User not found");
      };
      case (?user) {
        switch (user.accessLevel) {
          case (#ADMIN) {
            return #ok("You are an ADMIN");
          };
          case (#USER) {
            return #ok("You are just a USER");
          };
          case (#GUEST) {
            return #ok("You are a GUEST");
          };
        };
      };
    };
  };
};
