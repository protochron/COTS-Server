package norris.cotsbots.servertest;

import android.app.Activity;
import android.os.Bundle;
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
			new JSONTask(this).execute(JSONData.helloJSON());
			
		}
	}
}
