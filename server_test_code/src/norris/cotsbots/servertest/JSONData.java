package norris.cotsbots.servertest;

import org.json.JSONException;
import org.json.JSONObject;

public class JSONData {
	
	//Constant responses
	//Unused at the moment, but good for comparing or constructing JSON objects
	static public String failure = "{\"response\":400}";
	static public String success = "{\"response\":200}";
	static public String vagueFailure = "{\"response\":500}";
	
	/***********************************************
	 * Example of constructing a simple JSON object
	 * @return String response
	 ***********************************************/
	static public String helloJSON(){
		JSONObject response = new JSONObject();
		try {
			response = new JSONObject().put("message", "This is just a simple JSON object.");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return response.toString();
	}

}
