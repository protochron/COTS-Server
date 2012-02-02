package edu.cotsbots.servertest;

import java.io.ByteArrayOutputStream;

import norris.cotsbots.servertest.R;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

/********************************************************************************
 * Connect to a socket, send a simple JSON object and report the server response
 * 
 * @author Daniel Norris
 *********************************************************************************/
public class COTSBotsServerTestActivity extends Activity implements
		OnClickListener {

	Button sendDataButton;
	Button insertDataButton;
	public static String TAG = "COTS_SERVER"; //This should be changed for your individual project

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		sendDataButton = (Button) findViewById(R.id.app_sendJSONButton);
		sendDataButton.setOnClickListener(this);
		
		insertDataButton = (Button) findViewById(R.id.app_insertData);
		insertDataButton.setOnClickListener(this);
	}

	/**************************************
	 * onClick handler for this activity.
	 *************************************/
	@Override
	public void onClick(View v) {
		//This part only works if it is using WiFi and not 3G
		WifiManager manager = (WifiManager) getSystemService(Context.WIFI_SERVICE);
		int ip = manager.getConnectionInfo().getIpAddress();
		//Parse the integer representation into a string
		String ipAddr = String.format("%d.%d.%d.%d",
				(ip & 0xff),
				(ip >> 8 & 0xff),
				(ip >> 16 & 0xff),
				(ip >> 24 & 0xff));
		if (v == sendDataButton) {
			new JSONTask(this).execute(JSONData.helloJSON(ipAddr));
		}
		else if (v == insertDataButton) {
			Log.d(TAG, "Starting to convert image");
			JSONData data = new JSONData(ipAddr);
			
			String imagefile = "/sdcard/sample.jpg";
			
			//Load file and convert to byte array
			Bitmap bm = BitmapFactory.decodeFile(imagefile);
			ByteArrayOutputStream stream = new ByteArrayOutputStream();
			bm.compress(Bitmap.CompressFormat.JPEG, 100, stream);
			byte[] imageArray = stream.toByteArray();
			
			data.insertBinary(imageArray, "jpg");
			//Log.d(TAG, data.toString());
			
			new JSONTask(this).execute(data.toString());
			
		}
	}
}
