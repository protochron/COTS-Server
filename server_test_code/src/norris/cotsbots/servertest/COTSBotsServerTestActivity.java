package norris.cotsbots.servertest;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;

import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

/**
 * Connect to a socket, send a simple JSON object and report the server response
 * 
 * @author Daniel Norris
 * 
 */
public class COTSBotsServerTestActivity extends Activity implements
		OnClickListener {

	Button sendDataButton;
	String tag = "COTS_SERVER";

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		sendDataButton = (Button) findViewById(R.id.app_sendJSONButton);
		sendDataButton.setOnClickListener(this);
	}

	/****
	 * Sends a simple JSON object to the server and gets the server response.
	 * @return Server response
	 */
	public String sendTestJSON() {
		
		//The server address refers to localhost on the computer running the android emulator
		//This should be changed once a suitable server is available.
		String server = "10.0.2.2";
		int port = 8085;
		String response = "";

		try {
			Socket socket = new Socket(server, port);
			if (socket.isConnected()) {
				PrintWriter outStream = new PrintWriter(
						socket.getOutputStream(), true);
				
				
				outStream.println(JSONData.helloJSON());
				outStream.flush();
				
				
				BufferedReader inStream = new BufferedReader(
						new InputStreamReader(socket.getInputStream()));
				
				response = inStream.readLine();
				
				outStream.close();
				inStream.close();
				socket.close();
				return response;
			}
			else
				socket.close();
				response = "Unable to connect";

		} catch (UnknownHostException e) {
			e.printStackTrace();
			response = "Unknown host.\n".concat(e.getMessage());
		} catch (IOException e) {
			e.printStackTrace();
			response = "Could not connect\n".concat(e.getMessage());
		}
		return response;
	}

	@Override
	public void onClick(View v) {
		if (v == sendDataButton) {
			Log.d(tag, "Trying to send some JSON");
			String response = sendTestJSON();
			Log.d(tag, "Response was: " + response);
			
			AlertDialog dialog = new AlertDialog.Builder(
					COTSBotsServerTestActivity.this).create();
			dialog.setTitle("Server Response");
			dialog.setMessage(response);
			
			//Set what the button does
			dialog.setButton(AlertDialog.BUTTON_NEUTRAL, "Close",
					new DialogInterface.OnClickListener() {

						@Override
						public void onClick(DialogInterface dialog, int which) {
							dialog.dismiss();

						}
					});
			dialog.show();
		}
	}

}
