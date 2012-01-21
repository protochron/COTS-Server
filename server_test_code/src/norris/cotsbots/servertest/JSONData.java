package norris.cotsbots.servertest;

import org.json.JSONException;
import org.json.JSONObject;

public class JSONData {
	
	static public String validResponse() {
		JSONObject response = new JSONObject();
		try {
			response = new JSONObject().put("response", 200);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return response.toString();
	}
	
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
