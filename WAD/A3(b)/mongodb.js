const {MongoClient}=require("mongodb");
const url="mongodb+srv://latesh:latesh@cluster0.aqhqpqm.mongodb.net/student?retryWrites=true&w=majority";
const database="student";
const client=new MongoClient(url);
const dbConnect=async()=>{
    const result=await client.connect();
    const db=await result.db(database);
    return db.collection("profile");
}
module.exports=dbConnect;