import java.sql.*;
import java.util.Scanner;
import java.util.Date;


public class Bank
{
	private static int v1,v5;
	private static String v2,v3,v4;
	
	static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
	
	static final String DB_URL = "jdbc:mysql://localhost/BANK";
	
	static final String USER = "root";
	
	static final String PASS = "";

	Bank()
	{
		Connection conn = null;
		
		Statement stmt = null;

		PreparedStatement stmnt = null;
		PreparedStatement stmnt1 = null;

		String sql = null;
		String sql1 = null;

		Scanner s = new Scanner(System.in);
		
		int opt,ac_no;
		try
		{
			Class.forName(JDBC_DRIVER);
		
			System.out.println("Connecting to BANK database...");
			conn = DriverManager.getConnection(DB_URL, USER, PASS);
			System.out.println("Connected to database successfully...");
		
			do
			{
				System.out.print("\n1.Account Opening\n2.Deposit\n3.Withdrawal\n4.Bank Statement\n5.Exit\nEnter your choice:");
				opt=s.nextInt();
				switch(opt)
				{
					case 1:
					
					v1=(int)((Math.random()*9000000)+1000000);			s.nextLine();
					System.out.print("Enter your FIRST NAME:\t");
					v2=s.nextLine();
					System.out.print("Enter your LAST NAME:\t");
					v3=s.nextLine();
					System.out.print("Enter your ADDRESS:\t");
					v4=s.nextLine();
					System.out.print("Enter your OPENING DEPOSIT AMOUNT:\t");
					v5=s.nextInt();
					if(v5>=1000)
					{
						sql = "INSERT INTO customers (acc_num,f_name,l_name,address,open_dep) VALUES(?,?,?,?,?)" ;
					
						stmnt = conn.prepareStatement(sql);
					
						stmnt.setInt(1, v1);
						stmnt.setString(2, v2);
						stmnt.setString(3, v3);
						stmnt.setString(4, v4);
						stmnt.setInt(5, v5);
					
						stmnt.executeUpdate();
										
						Date date = new Date();
						Timestamp ts = new Timestamp(date.getTime());
								
						sql="INSERT into transactions (acc_num,date_of_trans,avail_amount) VALUES(?,?,?)";
					
						stmnt = conn.prepareStatement(sql);
					
						stmnt.setInt(1, v1);
						stmnt.setTimestamp(2, ts);
						stmnt.setInt(3, v5);
					
						stmnt.executeUpdate();
					
						System.out.println(v2+"'s account has been created with account number "+v1);
					}
					else
					{
						System.out.println("\nOpening deposit amount must be greater than or equal to 1000INR");
						System.out.println("Have a nice day ahead!");
						
						System.exit(0);
					}
					break;
					
					
					case 2:
					
					System.out.print("Enter account number in which amount has to be credited:\t");
					ac_no=s.nextInt();
					System.out.print("Enter amount to be deposited:\t");
					int add_bal=s.nextInt();
					if(add_bal>=100)
					{
					Date date = new Date();
					Timestamp ts = new Timestamp(date.getTime());
					
					sql="update transactions set avail_amount=avail_amount + ? where acc_num =?";
					sql1="update transactions set date_of_trans=? where acc_num=?";
					
					stmnt = conn.prepareStatement(sql);
					
					stmnt1 = conn.prepareStatement(sql1);
					
					stmnt.setInt(1, add_bal);
					stmnt.setInt(2, ac_no);
					
					stmnt1.setTimestamp(1,ts);
					stmnt1.setInt(2,ac_no);
					
					int flag=stmnt.executeUpdate();
					
					stmnt1.executeUpdate();
					
					if(flag>0)
					System.out.println("Amount Deposited in Account Number "+ac_no);
					else
					System.out.println("Account does not exists");
					}
					else
					{
					System.out.println("Amount must not be negative	and must be above 100INR");
					}
					break;
				
				
					case 3:
					
					System.out.print("Enter account number in which the amount has to be withdrawn from:\t");
					ac_no=s.nextInt();
					System.out.print("How much money is to be withdrawn:\t");
					int sub_bal=s.nextInt();
					if(sub_bal>100)
					{
					Date date = new Date();
					Timestamp ts = new Timestamp(date.getTime());
					
					sql="update transactions set avail_amount=avail_amount - ? where acc_num =?";
					sql1="update transactions set date_of_trans=? where acc_num=?";
					
					stmnt = conn.prepareStatement(sql);
					
					stmnt1 = conn.prepareStatement(sql1);
					
					stmnt.setInt(1, sub_bal);
					stmnt.setInt(2, ac_no);
					
					stmnt1.setTimestamp(1,ts);
					stmnt1.setInt(2,ac_no);
					
					int flag=stmnt.executeUpdate();
					
					stmnt1.executeUpdate();
					if(flag>0)
					System.out.println("An amount of Rs."+sub_bal+" has been debited from Account Number "+ac_no);
					else
					System.out.println("Account does not exists");
					}
					else
					{
					System.out.println("Amount must not be negative	and must be above 100INR");
					}
					
					break;
					
					
					case 4:
					
					System.out.print("Enter the account number for which you want the Bank Statement for:\t");
					ac_no=s.nextInt();
					
					sql = "select c.acc_num,c.f_name,c.l_name,c.address,t.date_of_trans,t.avail_amount from customers c,transactions t where c.acc_num=? AND t.acc_num=?";
					
					stmnt = conn.prepareStatement(sql);
					
					stmnt.setInt(1, ac_no);
					stmnt.setInt(2, ac_no);
					
					
					ResultSet rs = stmnt.executeQuery();
					
					if(rs.getRow()==0)
					System.out.println("Account does not exists");
					
					while(rs.next())
					{
						System.out.print("Account Number: " + rs.getInt(1));
						System.out.print(" | First Name: " + rs.getString(2));
						System.out.print(" | Last Name: " + rs.getString(3));
						System.out.print(" | Address: " + rs.getString(4));
						System.out.print(" | Date & Time of last transaction: " + rs.getTimestamp(5));
						System.out.print(" | Available Balance: " + rs.getInt(6)+"\n");
					}
					
					rs.close();
				
					break;
					
					case 5:
					
					System.out.println("\nHave a nice day ahead!");
					System.exit(0);
					
					break;
					
					default:
					{
						System.out.println("Invalid choice. Exitting due to security reasons.\nHave a nice day ahead!");
						System.exit(0);
					}
					break;
				}
			}while(opt<=5);
		}
		catch(SQLException se)
		{
			se.printStackTrace();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			try
			{
				if(stmnt!=null)
				stmnt.close();
			}
			catch(SQLException se)
			{
				se.printStackTrace();
			}
			try
			{
				if(conn!=null)
				conn.close();
			}
			catch(SQLException se)
			{
				se.printStackTrace();
			}
		}
System.out.println("\nHave a nice day ahead!");
	}
	public static void main(String[] args)
	{
	Bank bnk=new Bank();
	}
}

