import java.io.*;
import java.sql.*;

class JDBCDemoProgram
{
	static BufferedReader br=new BufferedReader(new InputStreamReader(System.in));
static Connection conn=null;
PreparedStatement ps=null;

static String name, regdnum, email, branch;


JDBCDemoProgram() throws Exception
{
	Class.forName("com.mysql.jdbc.Driver");
	conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/Demo","root","");
}

void insertIntoTable() throws SQLException, IOException
{
	int flg=0;
	name=br.readLine();
	regdnum=br.readLine();
	email=br.readLine();
	branch=br.readLine();
	ps=conn.prepareStatement("select * from students");
	ResultSet rs=ps.executeQuery();
	while(rs.next()){
		if(rs.getString(2).equals(regdnum))
			flg=0;
			else
				flg=1;
	}
	if(flg==1){
ps=conn.prepareStatement("insert into students(name, regdnum, email, branch) values (?,?,?,?)");
ps.setString(1, name);
ps.setString(2, regdnum);
ps.setString(3, email);
ps.setString(4, branch);
int flag = ps.executeUpdate();
if(flag==1)
{
System.out.println("Successfully Inserted");
}
else
{
System.out.println("Insertion failed");
}}
	else
	{System.out.println("entered regd number is already registered");}
}

void deleteFromTable(String regdnum) throws SQLException
{
ps=conn.prepareStatement("delete from students where regdnum=?");
ps.setString(1, regdnum);
int flag = ps.executeUpdate();
if(flag==1)
{
System.out.println("Successfully Deleted");
}
else
{
System.out.println("Deletion failed");
}
}

void retrieval() throws SQLException
{
	ps=conn.prepareStatement("select * from students");
	ResultSet rs=ps.executeQuery();
	while(rs.next()){
		System.out.println("Name:"+rs.getString(1));
		System.out.println("Regd. Num:"+rs.getString(2));
		System.out.println("Email:"+rs.getString(3));
		System.out.println("Branch:"+rs.getString(4));
		System.out.println("\n");
	}
}

public static void main(String a[]) throws Exception
{

JDBCDemoProgram jdb=new JDBCDemoProgram();

while(true){
System.out.println("1.Insert\n2.Delete\n3.Display");
int choice=Integer.parseInt(br.readLine());
switch(choice){
case 1:
jdb.insertIntoTable(); break;
case 2:
	System.out.println("enter regd number to be deleted:");
	regdnum=br.readLine();
	jdb.deleteFromTable(regdnum);	break;
case 3:
	jdb.retrieval();	break;
default:
	System.out.println("Invalid Choice. Connection CLosed. Bye");
	conn.close();
	System.exit(0);
}	
}
}
}
