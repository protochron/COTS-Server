package edu.cotsbots.servertest;

import java.sql.Timestamp;
import java.util.Calendar;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Base64;
import android.util.Log;

/********************************************************
 * Class that contains static methods to create JSON data
 * 
 * @author Daniel Norris
 *******************************************************/
public class JSONData {

	// Constant responses
	// Most are unused at the moment, but good for comparing or constructing
	// JSON objects
	static public String failure = "{\"response\":400}";
	static public String success = "{\"response\":200}";
	static public String vagueFailure = "{\"response\":500}";
	static public String serverUnavailable = "{\"response\":503}";
	static public String responseField = "response";

	// Server directives and fields
	static private String INSERT = "insert";
	static private String TIMESTAMP = "timestamp";
	static private String ID = "id";
	static private String DATA = "data";
	static private String EXT = "ext";
	static private String BINARY = "binary";

	// JSON data to send
	private JSONObject data;

	public JSONData(String ip) {
		data = new JSONObject();
		try {
			Timestamp stamp = new Timestamp(Calendar.getInstance()
					.getTimeInMillis());
			data.put(TIMESTAMP, stamp.toString());
			data.put(ID, ip);
		} catch (JSONException e) {
			Log.e(COTSBotsServerTestActivity.TAG, e.getMessage());
		}
	}

	/******************************************************
	 * Method to add data to insert on the server. This appends data to the
	 * insert field.
	 * 
	 * @param dataToInsert
	 * @param binary
	 ******************************************************/
	public void insertBinary(byte[] dataToInsert, String extension) {
		try {
			JSONObject binary = new JSONObject().put(DATA,
					Base64.encodeToString(dataToInsert, Base64.URL_SAFE));
			binary.put(EXT, "jpg");
			data.accumulate(BINARY, binary);
		} catch (JSONException e) {
			Log.e(COTSBotsServerTestActivity.TAG,
					"Failed to find insert" + e.getMessage());
		}
	}

	/***********************************************
	 * Example of constructing a simple JSON object
	 * 
	 * @param ip
	 * @return String response
	 ***********************************************/
	static public String helloJSON(String ip) {
		JSONObject response = new JSONObject();
		try {
			Timestamp stamp = new Timestamp(Calendar.getInstance()
					.getTimeInMillis());
			response = new JSONObject().put("timestamp", stamp.toString());
			response.put(ID, ip);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return response.toString();
	}

	/******************************************************
	 * Return the string representation of the JSON object
	 * 
	 * @return String representation of JSON object.
	 ******************************************************/
	public String toString() {
		return data.toString();
	}
}
