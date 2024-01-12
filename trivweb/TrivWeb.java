package trivweb;
import java.io.File;
import org.bzdev.ejws.*;
import org.bzdev.ejws.maps.*;
import java.net.*;

public class TrivWeb {

    public static void main(String argv[]) throws Exception {

	String pstr = System.getenv("PORT");
	int port = (pstr == null)? 80: Integer.parseInt(pstr);
	String target = System.getenv("TARGET");
	if (target == null) {
	    throw new Exception("environment variable TARGET missing");
	}

	String ts = System.getenv("TRACE");
	boolean trace = (ts == null)? false: ts.equalsIgnoreCase("true");

	InetSocketAddress saddr = new InetSocketAddress("0.0.0.0", port);

	EmbeddedWebServer ews = new
	    EmbeddedWebServer(saddr.getAddress(), port, 48, 10, null);

	if (target.startsWith("http://")
	    || target.startsWith("https://")
	    || target.startsWith("ftp://")) {
	    // redirect case
	    URL url = new URL(target);
	    ews.add("/", RedirectWebMap.class, url, null, true, false, true);
	} else {
	    File f = new File(target);
	    File dir = f.isDirectory()? f: f.getParentFile();
	    ews.add("/", DirWebMap.class, dir, null, true, (f == dir), true);
	    if (f != dir) {
		WebMap map = ews.getWebMap("/");
		map.addWelcome(f.getName());
	    }
	}
	if (trace) ews.setTracer("/", System.out, true);
	ews.start();
    }
}
