package norris.cotsbots.servertest;

import java.sql.Timestamp;
import java.util.Calendar;

import org.json.JSONException;
import org.json.JSONObject;

public class JSONData {

	// Constant responses
	// Unused at the moment, but good for comparing or constructing JSON objects
	static public String failure = "{\"response\":400}";
	static public String success = "{\"response\":200}";
	static public String vagueFailure = "{\"response\":500}";
	static public String serverUnavailable = "{\"response\":503}";
	static public String responseField = "response";

	/***********************************************
	 * Example of constructing a simple JSON object
	 * 
	 * @return String response
	 ***********************************************/
	static public String helloJSON(String ip) {
		JSONObject response = new JSONObject();
		try {
			Timestamp stamp = new Timestamp(Calendar.getInstance()
					.getTimeInMillis());
			response = new JSONObject().put("timestamp", stamp.toString());
			response.put("ip", ip);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return response.toString();
	}
}
