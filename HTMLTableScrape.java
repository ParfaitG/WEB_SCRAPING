
import java.util.ArrayList;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;


public class WebScrape {

  public static void main(String[] args) {

	String currentDir = new File("").getAbsolutePath();
	
	Document doc;	
	ArrayList<String> titlesdata;           
        titlesdata = new ArrayList<String>();
	
	ArrayList<String> authorsdata;  
	authorsdata = new ArrayList<String>();
	
	try {
				
		// Open CSV
		FileWriter writer = new FileWriter(currentDir + "\\HTMLDATA_java.csv");
		
		//Write the CSV file header
		writer.append("Title,Author\n");		
		
		// Connect to HTML page and get content
		doc = Jsoup.connect("http://www.bartleby.com/titles/").timeout(10*1000).get();

		// Extract Table Data
		Elements titles = doc.select("TR > TD");		
		
		for (Element item : titles) {
				
			// Extract values to list			
			if (item.select("A:eq(0)").text().length() > 0 && item.select("A:eq(0)").text().length()
			    item.select("A:eq(0)").text().length() < 255 && item.select("A:eq(1)").text().length() < 255) {
				
				titlesdata.add(item.select("A:eq(0)").text());
				writer.append("\"" + item.select("A:eq(0)").text() + "\"" );					
				writer.append(",");			
				
				authorsdata.add(item.select("A:eq(1)").text());
				writer.append("\"" + item.select("A:eq(1)").text() + "\"");				
				writer.append("\n");
			}			
		}
			
		writer.flush();
		writer.close();
		
		System.out.println("Successfully HTML data to CSV file!");
		
	} catch (IOException e) {
		e.printStackTrace();
	}

  }

}