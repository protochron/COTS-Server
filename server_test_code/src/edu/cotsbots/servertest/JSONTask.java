package edu.cotsbots.servertest;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.util.Log;

/************************************************************************
 * JSONTask Creates an AsyncTask that sends and receives JSON data to an
 * external server.
 * 
 * @author Daniel Norris
 ************************************************************************/
public class JSONTask extends AsyncTask<String, Void, String> {

	private ProgressDialog dialog;
	private Activity baseActivity; // reference to the activity that called this
									// task

	// Constructor
	public JSONTask(Activity a) {
		baseActivity = a;
	}

	// Before the AsyncTask starts
	@Override
	protected void onPreExecute() {
		dialog = new ProgressDialog(baseActivity);
		dialog.setMessage("Waiting for server response...");
		dialog.show();
	}

	// Define what to do in the background for this task
	@Override
	protected String doInBackground(String... params) {
		Log.d(COTSBotsServerTestActivity.TAG, "Trying to send some JSON");
		return sendJSON(params[0]);
	}

	// Show a dialog with the server response once we get one
	@Override
	protected void onPostExecute(String result) {
		Log.d(COTSBotsServerTestActivity.TAG, "Response was: " + result);

		// Get rid of the progress dialog if its still running
		if (dialog.isShowing()) {
			dialog.dismiss();
		}

		// Show an alert dialog telling us what the server said
		AlertDialog dialog = new AlertDialog.Builder(baseActivity).create();
		dialog.setTitle("Server Response");

		// Convert the JSON response (more of an example of how to do it)
		try {
			JSONObject converter = new JSONObject(result);
			dialog.setMessage("Response: "
					+ converter.getString(JSONData.responseField));
		} catch (JSONException e) {
			Log.e(COTSBotsServerTestActivity.TAG, e.getMessage());
			dialog.setMessage("Error parsing JSON");
		}

		// Set what the button does
		dialog.setButton(AlertDialog.BUTTON_NEUTRAL, "Close",
				new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				});

		dialog.show();
	}

	/*************************************************************************
	 * Sends a simple JSON object to the server and gets the server response.
	 * 
	 * @return String response
	 *************************************************************************/
	public String sendJSON(String json) {

		// The server address refers to localhost on the computer running the
		// android emulator
		// This should be changed once a suitable server is available.
		// String server = "10.0.2.2";
		String server = "daevaofshadow.dyndns.org";
		int port = 8080;
		String response = "";

		// Easier to leave the work in the try block
		try {
			Socket socket = new Socket(server, port);
			PrintWriter outStream = new PrintWriter(socket.getOutputStream(),
					true);
			BufferedReader inStream = new BufferedReader(new InputStreamReader(
					socket.getInputStream()));

			outStream.println(json);
			outStream.flush();
			Log.d(COTSBotsServerTestActivity.TAG, "Reading response.");
			response = inStream.readLine();
			if (response == null)
				response = JSONData.serverUnavailable;

			// Cleanup
			outStream.close();
			inStream.close();
			socket.close();

		} catch (UnknownHostException e) {
			e.printStackTrace();
			response = JSONData.serverUnavailable;
		} catch (IOException e) {
			e.printStackTrace();
			response = JSONData.serverUnavailable;
		}
		return response;
	}
}
