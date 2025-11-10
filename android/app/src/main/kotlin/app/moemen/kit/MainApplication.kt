package app.moemen.kit

import android.util.Log
import androidx.work.Configuration
import dev.fluttercommunity.plus.androidalarmmanager.AndroidAlarmManager
import io.flutter.embedding.android.FlutterApplication
import io.flutter.plugins.GeneratedPluginRegistrant
import workmanager.WorkmanagerPlugin

class MainApplication : FlutterApplication(), Configuration.Provider {
    override fun onCreate() {
        super.onCreate()
        AndroidAlarmManager.initialize(this)
        WorkmanagerPlugin.setPluginRegistrantCallback { registry ->
            GeneratedPluginRegistrant.registerWith(registry)
        }
    }

    override fun getWorkManagerConfiguration(): Configuration {
        return Configuration.Builder()
            .setMinimumLoggingLevel(Log.INFO)
            .build()
    }
}
