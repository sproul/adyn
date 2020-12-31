import java.io.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;

class apply_xsl
{
  public static void main(String[] arguments)
  {
		String style = arguments[0];
		String XML = arguments[1];
		String HTML = arguments[2];
		System.out.println("apply_xsl applying " + style + " to " + XML + " => " + HTML);
		TransformerFactory factory = TransformerFactory.newInstance();
 		try
		{
			Transformer transformer = factory.newTransformer(new StreamSource(new FileInputStream(style)));
			transformer.transform(new StreamSource(new FileInputStream(XML)),
														new StreamResult(new FileOutputStream(HTML)));
		}
		catch(Exception e)
		{
			System.out.println("main: caught exception: " + e);
		}

 	}
}
