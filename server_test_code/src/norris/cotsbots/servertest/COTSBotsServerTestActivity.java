package norris.cotsbots.servertest;

import android.app.Activity;
import android.content.Context;
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
	public static String TAG = "COTS_SERVER";

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		sendDataButton = (Button) findViewById(R.id.app_sendJSONButton);
		sendDataButton.setOnClickListener(this);
	}

	/**************************************
	 * onClick handler for this activity.
	 *************************************/
	@Override
	public void onClick(View v) {
		if (v == sendDataButton) {
			//ConnectivityManager conn = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
			//conn.getActiveNetworkInfo().
			WifiManager manager = (WifiManager) getSystemService(Context.WIFI_SERVICE);
			int ip = manager.getConnectionInfo().getIpAddress();
			//Parse the integer representation into a string
			String ipAddr = String.format("%d.%d.%d.%d",
					(ip & 0xff),
					(ip >> 8 & 0xff),
					(ip >> 16 & 0xff),
					(ip >> 24 & 0xff));
			new JSONTask(this).execute(JSONData.helloJSON(ipAddr));
		}
	}
}
